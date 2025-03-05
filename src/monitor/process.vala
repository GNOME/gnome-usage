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

public class Usage.Process : Object {
    public Pid pid { get; private set; }
    public string cmdline { get; private set; }
    public uint uid { get; private set; }
    public uint64 start_time { get; set; default = 0; }

    private bool _cgroup_read = false;
    private string? _cgroup;
    public string? cgroup {
        get {
            if (!this._cgroup_read) {
                this._cgroup = Process.read_cgroup (this.pid);
                this._cgroup_read = true;
            }

            return this._cgroup;
        }
    }

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

    public Process (Pid pid) {
        this.pid = pid;
        this.cmdline = get_full_process_cmd (pid);
        this.uid = _get_uid ();
    }

    public void update_status () {
        GTop.ProcState proc_state;
        GTop.get_proc_state (out proc_state, pid);

        switch (proc_state.state) {
            case GTop.PROCESS_RUNNING:
            case GTop.PROCESS_UNINTERRUPTIBLE:
                this.status = ProcessStatus.RUNNING;
                break;
            case GTop.PROCESS_SWAPPING:
            case GTop.PROCESS_INTERRUPTIBLE:
            case GTop.PROCESS_STOPPED:
                this.status = ProcessStatus.SLEEPING;
                break;
            case GTop.PROCESS_DEAD:
            case GTop.PROCESS_ZOMBIE:
            default:
                if (this.cpu_load > 0) {
                    this.status = ProcessStatus.RUNNING;
                } else {
                    this.status = ProcessStatus.DEAD;
                }
                break;
        }

        this.mark_as_updated = true;
    }

    private uint _get_uid () {
        GTop.ProcUid procUid;
        GTop.get_proc_uid (out procUid, pid);
        return procUid.uid;
    }

    public string? app_id {
        get {
            if (!this._app_id_checked) {
                this._app_id = read_app_id (pid);
                this._app_id_checked = true;
            }

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
        for (int i = 0; i < uint.min (args.length, 2); i++) {
            if (args[i] == null)
                continue;

            /* TODO: this will fail if args[i] is a commandline,
             * i.e. composed of multiple segments and one of the
             * later ones is a unix path */
            var name = Path.get_basename (args[i]);
            if (!name.contains (cmd))
                continue;

            name = Process.first_component (name);
            return Process.sanitize_name (name);
        }

        return Process.sanitize_name (cmd);
    }

    public static string? read_cgroup (Pid pid) {
        string path = "/proc/%u/cgroup".printf ((uint) pid);

        try {
            File file = File.new_for_path (path);

            uint8[] contents;
            file.load_contents (null, out contents, null);

            string line = ((string) contents).split ("\n")[0];

            // Only do anything with cgroup v2
            if (!line.has_prefix ("0::"))
                return null;

            return line[3:line.length];
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
        string path = "/proc/%u/root/.flatpak-info".printf ((uint) pid);
        int flags = Posix.O_RDONLY | StopGap.O_CLOEXEC | Posix.O_NOCTTY;

        int fd = StopGap.openat (StopGap.AT_FDCWD, path, flags);

        if (fd == -1)
            return null;

        KeyFile kf = new KeyFile ();

        try {
            MappedFile file = new MappedFile.from_fd (fd, false);
            kf.load_from_data ((string) file.get_contents (), file.get_length (), 0);
        } catch (Error e) {
            return null;
        }

        Posix.close (fd);

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
        return str.split (" ", 2)[0];
    }
}

public enum Usage.ProcessStatus {
    RUNNING,
    SLEEPING,
    DEAD;
}
