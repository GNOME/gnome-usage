/* process-monitor.vala
 *
 * Copyright (C) 2025 Markus Göllnitz
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.ProcessMonitor : Monitor, Object {
    private unowned SystemMonitor parent_monitor;
    private HashTable<GLib.Pid, Process> process_table = new HashTable<GLib.Pid, Process> (direct_hash, direct_equal);

    private static int PROCESS_MODE = GTop.KERN_PROC_ALL;

    public ProcessMonitor (SystemMonitor parent_monitor) {
        this.parent_monitor = parent_monitor;
    }

    public void init () {
        foreach (Process p in this.process_table.get_values ()) {
            this.process_added (p);
        }
    }

    public void update () {
        foreach (AppItem app in this.parent_monitor.app_table.get_values ()) {
            app.mark_as_not_updated ();
        }

        /* Try to find the difference between the old list of pids,
         * and the new ones, i.e. the one that got added and removed */
        GTop.Proclist proclist;
        Pid[] pids = GTop.get_proclist (out proclist, PROCESS_MODE);
        intptr[] old = (intptr[]) this.process_table.get_keys_as_array ();

        size_t new_len = (size_t) proclist.number;
        size_t old_len = this.process_table.length;

        sort_pids (pids, sizeof (GLib.Pid), new_len);
        sort_pids (old, sizeof (intptr), old_len);

        debug ("new_len: %lu, old_len: %lu\n", new_len, old_len);
        uint removed = 0;
        uint added = 0;
        size_t i = 0, j = 0;
        while (i < new_len || j < old_len) {
            uint32 n = i < new_len ? pids[i] : uint32.MAX;
            uint32 o = j < old_len ? (uint32) old[j] : uint32.MAX;

            /* pids: [ 1, 3, 4 ]
             * old:  [ 1, 2, 4, 5 ] → 2,5 removed, 3 added
             * i [for pids]: 0  |   1   |   1   |   2  |   3
             * j [for old]:  0  |   1   |   2   |   2  |   3
             * n = pids[i]:  1  |   3   |   3   |   4  |  MAX [oob]
             * o = old[j]:   1  |   2   |   4   |   4  |   5
             *               =  | n > o | n < o |   =  | n > o
             * increment:   i,j |   j   |   i   |  i,j |   j
             * Process op:  chk |  del  |  add  |  chk |  del
             */

            if (n > o) {
                /* delete to process not in the new array */
                Process p = (!) this.process_table[(GLib.Pid) o];
                debug ("process removed: %u\n", o);

                this.process_removed (p);
                removed++;

                j++; /* let o := old[j] catch up */
            } else if (n < o) {
                /* new process */
                Process p = new Process ((GLib.Pid) n);
                this.update_process (ref p);

                debug ("process added: %u\n", n);

                this.process_added (p);
                added++;

                i++; /* let n := pids[i] catch up */
            } else {
                /* equal pids, might have rolled over though
                 * better check, match start time */
                Process p = (!) this.process_table[(GLib.Pid) n];

                GTop.ProcTime ptime;
                GTop.get_proc_time (out ptime, p.pid);

                /* no match: -> old removed, new added */
                if (ptime.start_time != p.start_time) {
                    debug ("start time mismtach: %u\n", n);
                    this.process_removed (p);

                    p = new Process ((GLib.Pid) n);
                    this.process_added (p);
                }

                this.update_process (ref p);

                i++; j++; /* both indices move */
            }
        }

        foreach (AppItem app in this.parent_monitor.app_table.get_values ()) {
            app.remove_processes ();
        }

        debug ("removed: %u, added: %u\n", removed, added);
        debug ("app table size: %u\n", this.parent_monitor.app_table.length);
        debug ("process table size: %u\n", this.process_table.length);
    }

    public void update_process (ref Process process) {
        foreach (Monitor monitor in this.parent_monitor.monitors) {
            if (monitor != this) {
                monitor.update_process (ref process);
            }
        }
        process.mark_as_updated = true;
    }

    private void process_added (Process p) {
        string app_id = this.get_app_id_for_process (p);

        AppItem? item = this.parent_monitor.app_table[app_id];

        if (item == null) {
            this.parent_monitor.app_table.insert (app_id, new AppItem (p));
        } else if (!((!) item).contains_process (p.pid)) {
            ((!) item).insert_process (p);
        }

        this.process_table.insert (p.pid, p);
    }

    private void process_removed (Process p) {
        AppItem? item = AppItem.app_item_for_process (p);

        item?.remove_process (p);
        this.process_table.remove (p.pid);
    }

    private string get_app_id_for_process (Process p) {
        AppInfo? info = AppItem.app_info_for_process (p);

        return info?.get_id () ?? (
            this.parent_monitor.group_system_apps ? (
                p.cgroup == "/lxc.payload.waydroid" ? "system_waydroid" : "system"
            ) : p.cmdline
        );
    }

    public static void sort_pids (void *pids, size_t elm, size_t length) {
        Posix.qsort (pids, length, elm, (a, b) => {
            return (*(GLib.Pid *) a) - (* (GLib.Pid *) b);
        });
    }
}
