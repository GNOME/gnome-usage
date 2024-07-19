/* system-monitor.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

public class Usage.SystemMonitor : Object {
    public bool process_list_ready { get; private set; default = false; }
    public double cpu_load { get; private set; }
    public double[] x_cpu_load { get; private set; }
    public uint64 ram_usage { get; private set; }
    public uint64 ram_total { get; private set; }
    public uint64 swap_usage { get; private set; }
    public uint64 swap_total { get; private set; }
    public bool group_system_apps { get; set; default = true; }

    private BackgroundMonitor background_monitor;
    private CpuMonitor cpu_monitor;
    private MemoryMonitor memory_monitor;
    private GameMode.PidList gamemode_pids;

    private HashTable<string, AppItem> app_table;
    private HashTable<GLib.Pid, Process> process_table;
    private int process_mode = GTop.KERN_PROC_ALL;
    private static SystemMonitor system_monitor;

    public static SystemMonitor get_default () {
        if (system_monitor == null)
            system_monitor = new SystemMonitor ();

        return system_monitor;
    }

    public List<unowned AppItem> get_apps () {
        return app_table.get_values ();
    }

    public unowned AppItem get_app_by_name (string name) {
        return app_table.@get (name);
    }

    public SystemMonitor () {
        GTop.init ();
        AppItem.init ();

        background_monitor = new BackgroundMonitor ();
        cpu_monitor = new CpuMonitor ();
        memory_monitor = new MemoryMonitor ();
        gamemode_pids = new GameMode.PidList ();

        app_table = new HashTable<string, AppItem> (str_hash, str_equal);
        process_table = new HashTable<GLib.Pid, Process> (direct_hash, direct_equal);
        var settings = Settings.get_default ();

        init ();
        this.notify["group-system-apps"].connect ((sender, property) => {
            init ();
        });

        Timeout.add (settings.data_update_interval, update_data);
    }

    private void init () {
        var settings = Settings.get_default ();
        app_table.remove_all ();
        process_list_ready = false;

        if (group_system_apps) {
            var system = new AppItem.system ();
            app_table.insert ("system" , system);
        }

        foreach (var p in process_table.get_values ()) {
            process_added (p);
        }

        update_data ();
        Timeout.add (settings.data_update_interval, () => {
            process_list_ready = true;
            return false;
        });
    }

    private bool update_data () {
        cpu_monitor.update ();
        memory_monitor.update ();

        cpu_load = cpu_monitor.get_cpu_load ();
        x_cpu_load = cpu_monitor.get_x_cpu_load ();
        ram_usage = memory_monitor.get_ram_usage ();
        ram_total = memory_monitor.get_ram_total ();
        swap_usage = memory_monitor.get_swap_usage ();
        swap_total = memory_monitor.get_swap_total ();

        foreach (var app in app_table.get_values ())
            app.mark_as_not_updated ();

        /* Try to find the difference between the old list of pids,
         * and the new ones, i.e. the one that got added and removed */
        GTop.Proclist proclist;
        var pids = GTop.get_proclist (out proclist, process_mode);
        intptr[] old = (intptr[]) process_table.get_keys_as_array ();

        size_t new_len = (size_t) proclist.number;
        size_t old_len = process_table.length;

        sort_pids (pids, sizeof (GLib.Pid), new_len);
        sort_pids (old, sizeof (intptr), old_len);

        debug ("new_len: %lu, old_len: %lu\n", new_len, old_len);
        uint removed = 0;
        uint added = 0;
        for (size_t i = 0, j = 0; i < new_len || j < old_len; ) {
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
                Process p = process_table[(GLib.Pid) o];
                debug ("process removed: %u\n", o);

                process_removed (p);
                removed++;

                j++; /* let o := old[j] catch up */
            } else if (n < o) {
                /* new process */
                var p = new Process ((GLib.Pid) n);
                update_process (ref p); // state, time

                debug ("process added: %u\n", n);

                process_added (p);
                added++;

                i++; /* let n := pids[i] catch up */
            } else {
                /* equal pids, might have rolled over though
                 * better check, match start time */
                Process p = process_table[(GLib.Pid) n];

                GTop.ProcTime ptime;
                GTop.get_proc_time (out ptime, p.pid);

                /* no match: -> old removed, new added */
                if (ptime.start_time != p.start_time) {
                    debug ("start time mismtach: %u\n", n);
                    process_removed (p);

                    p = new Process ((GLib.Pid) n);
                    process_added (p);
                }

                update_process (ref p);

                i++; j++; /* both indices move */
            }
        }

        foreach (var app in app_table.get_values ())
            app.remove_processes ();

        string[] background_app_ids = {};
        foreach (org.freedesktop.background.BackgroundApp background_app in background_monitor.get_background_apps ()) {
            background_app_ids += background_app.app_id;
        }
        app_table.foreach ((app_id, app) => {
            app.is_background = app_id.substring(0, app_id.length - ".desktop".length) in background_app_ids;
        });

        debug ("removed: %u, added: %u\n", removed, added);
        debug ("app table size: %u\n", app_table.length);
        debug ("process table size: %u\n", process_table.length);

        return true;
    }

    private void process_added (Process p) {
        string app_id = get_app_id_for_process (p);

        AppItem? item = app_table[app_id];

        if (item == null) {
            item = new AppItem (p);
            app_table.insert (app_id, item);
        } else if (! item.contains_process (p.pid)) {
            item.insert_process (p);
        }

        process_table.insert (p.pid, p);
    }

    private void process_removed (Process p) {
        AppItem? item = AppItem.app_item_for_process (p);

        if (item != null)
            item.remove_process (p);

        process_table.remove (p.pid);
    }

    private string get_app_id_for_process (Process p) {
        AppInfo? info = AppItem.app_info_for_process (p);

        return info?.get_id () ?? (
            group_system_apps ? (
                p.cgroup == "/lxc.payload.waydroid" ? "system_waydroid" : "system"
            ) : p.cmdline
        );
    }

    private void update_process (ref Process process) {
        cpu_monitor.update_process (ref process);
        memory_monitor.update_process (ref process);
        process.update_status ();
        process.gamemode = gamemode_pids.contains ((int) process.pid);
    }

    public static void sort_pids (void *pids, size_t elm, size_t length) {
        Posix.qsort (pids, length, elm, (a, b) => {
                return (*(GLib.Pid *) a) - (* (GLib.Pid *) b);
            });
    }
}
