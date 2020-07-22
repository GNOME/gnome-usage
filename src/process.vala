/* process.vala
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

namespace Usage
{
    public class Process : Object
    {
        public Pid pid { get; private set; }
        public string cmdline { get; private set; }
        public uint uid { get; private set; }
        public uint64 start_time { get; set; default = 0; }

        public double cpu_load { get; set; default = 0; }
        public double x_cpu_load { get; set; default = 0; }
        public uint64 cpu_last_used { get; set; default = 0; }
        public uint64 x_cpu_last_used { get; set; default = 0; }
        public uint last_processor { get; set; default = 0; }

        public uint64 mem_usage { get; set; default = 0; }

        public bool gamemode { get; set; }

        public bool mark_as_updated { get; set; default = true; }
        public ProcessStatus status { get; private set; default = ProcessStatus.SLEEPING; }

        private string? _app_id = null;
        private bool _app_id_checked = false;

        public Process(Pid pid)
        {
            this.pid = pid;
            this.cmdline = get_full_process_cmd (pid);
            this.uid = _get_uid();
        }

        public void update_status ()
        {
            GTop.ProcState proc_state;
            GTop.get_proc_state (out proc_state, pid);

            switch(proc_state.state)
            {
                case GTop.PROCESS_RUNNING:
                case GTop.PROCESS_UNINTERRUPTIBLE:
                    status = ProcessStatus.RUNNING;
                    break;
                case GTop.PROCESS_SWAPPING:
                case GTop.PROCESS_INTERRUPTIBLE:
                case GTop.PROCESS_STOPPED:
                    status = ProcessStatus.SLEEPING;
                    break;
                case GTop.PROCESS_DEAD:
                case GTop.PROCESS_ZOMBIE:
                default:
                    status = ProcessStatus.DEAD;
                    break;
            }

            if(cpu_load > 0)
                status = ProcessStatus.RUNNING;

            mark_as_updated = true;
        }

        private uint _get_uid()
        {
            GTop.ProcUid procUid;
            GTop.get_proc_uid(out procUid, pid);
            return procUid.uid;
        }

        public string? app_id {
            get {
                if (!_app_id_checked)
                    _app_id = read_app_id (pid);

                return _app_id;
            }
        }

        /* static pid related methods */
        public static string get_full_process_cmd (Pid pid) {
            GTop.ProcArgs proc_args;
            GTop.ProcState proc_state;
            string[] args = GTop.get_proc_argv (out proc_args, pid, 0);
            GTop.get_proc_state (out proc_state, pid);
            string cmd = (string) proc_state.cmd;

            /* cmd is most likely a truncated version, therefore
             * we check the first two arguments of the full argv
             * vector if they match cmd and if so, use that */
            for (int i = 0; i < 2; i++) {
                if (args[i] == null)
                    continue;

                /* TODO: this will fail if args[i] is a commandline,
                 * i.e. composed of multiple segments and one of the
                 * later ones is a unix path */
                var name = Path.get_basename (args[i]);
                if (!name.has_prefix (cmd))
                    continue;

                name = Process.first_component (name);
                return Process.sanitize_name (name);
            }

            return Process.sanitize_name (cmd);
        }

        public static string? read_cgroup (Pid pid) {
            string path = "/proc/%u/cgroup".printf ((uint) pid);
            int flags = Posix.O_RDONLY | StopGap.O_CLOEXEC | Posix.O_NOCTTY;

            int fd = StopGap.openat (StopGap.AT_FDCWD, path, flags);

            if (fd == -1)
                return null;

            try {
                string? data = null;
                string[] lines;
                string? cgroup = null;
                size_t len;

                // TODO use MappedFile.from_fd, requires vala 0.46
                IOChannel ch = new IOChannel.unix_new (fd);
                ch.set_close_on_unref (true);

                var status = ch.read_to_end (out data, out len);
                if (status != IOStatus.NORMAL)
                    return null;

                lines = data.split("\n");

                // Only do anything with cgroup v2
                if (!lines[0].has_prefix("0::"))
                    return null;

                cgroup = lines[0][3:lines[0].length];

                return cgroup;
            } catch (Error e) {
                return null;
            }
        }

        public static string? read_app_id (Pid pid) {
            KeyFile? kf = read_flatpak_info (pid);

            if (kf == null)
                return null;

            string? name = null;
            try {
                if (kf.has_key ("Application", "name"))
                    name = kf.get_string ("Application", "name");
            } catch (Error e) {
                warning (@"Failed to parse faltpak info for: $pid");
            }

            return name;
        }

        public static KeyFile? read_flatpak_info (Pid pid) {
            string path = "/proc/%u/root".printf ((uint) pid);
            int flags = Posix.O_RDONLY | StopGap.O_CLOEXEC | Posix.O_NOCTTY;

            int root = StopGap.openat (StopGap.AT_FDCWD, path, flags | Posix.O_NONBLOCK | StopGap.O_DIRECTORY);

            if (root == -1)
                return null;

            int fd = StopGap.openat (root, ".flatpak-info", flags);

            Posix.close (root);

            if (fd == -1)
                return null;

            KeyFile kf = new KeyFile ();

            try {
                string? data = null;
                size_t len;

                // TODO use MappedFile.from_fd, requires vala 0.46
                IOChannel ch = new IOChannel.unix_new (fd);
                ch.set_close_on_unref (true);

                var status = ch.read_to_end (out data, out len);
                if (status != IOStatus.NORMAL)
                    return null;

                kf.load_from_data (data, len, 0);
            } catch (Error e) {
                return null;
            }

            return kf;
        }

        /* static utility methods */
        public static string? sanitize_name (string name) {
            string? result = null;

            if (name == null)
                return null;

            try {
                var rgx = new Regex ("[^a-zA-Z0-9._-]");
                result = rgx.replace (name, name.length, 0, "");
            } catch (RegexError e) {
                warning ("Unable to sanitize name: %s", e.message);
            }

            return result;
        }

        public static string first_component (string str) {

            for (int i = 0; i < str.length; i++) {
                if (str[i] == ' ') {
                    return str.substring(0, i);
                }
            }

            return str;
        }
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}
