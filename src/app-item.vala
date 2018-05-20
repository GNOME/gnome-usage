namespace Usage
{
    public class AppItem : Object
    {
        public HashTable<Pid?, Process>? processes { get; set; }
        public string display_name { get; private set; }
        public string representative_cmdline { get; private set; }
        public uint representative_uid { get; private set; }
        public double cpu_load { get; private set; }
        public uint64 mem_usage { get; private set; }
        public Fdo.AccountsUser? user { get; private set; default = null; }

        private static GLib.List<AppInfo>? apps_info;
        private AppInfo app_info = null;

        public AppItem(Process process) {
            display_name = find_display_name(process.cmdline, process.cmdline_parameter);
            representative_cmdline = process.cmdline;
            representative_uid = process.uid;
            processes = new HashTable<Pid?, Process>(int_hash, int_equal);
            processes.insert(process.pid, process);

            if(apps_info == null)
                apps_info = AppInfo.get_all();

            load_user_account.begin();
        }

        public bool contains_process(Pid pid) {
            return processes.contains(pid);
        }

        public Icon get_icon()
        {
            var app_icon = (app_info == null) ? null : app_info.get_icon();

            if (app_info == null || app_icon == null)
                return new GLib.ThemedIcon("system-run-symbolic");
            else
                return app_icon;
        }

        public Process get_process_by_pid(Pid pid) {
            return processes.get(pid);
        }

        public void insert_process(Process process) {
            processes.insert(process.pid, process);
        }

        public void kill() {
            foreach(var process in processes.get_values()) {
                debug ("Terminating %d", (int) process.pid);
                Posix.kill(process.pid, Posix.Signal.KILL);
            }
        }

        public void mark_as_not_updated() {
            foreach(var process in processes.get_values())
                process.mark_as_updated = false;
        }

        public void remove_processes() {
            cpu_load = 0;
            mem_usage = 0;

            foreach(var process in processes.get_values()) {
                if(!process.mark_as_updated)
                    processes.remove(process.pid);
                else {
                    cpu_load += process.cpu_load;
                    mem_usage += process.mem_usage;
                }
            }

            cpu_load = double.min(100, cpu_load);
        }

        public void replace_process(Process process) {
            processes.replace(process.pid, process);
        }

        private string find_display_name(string cmdline, string cmdline_parameter) {
            foreach (AppInfo info in apps_info)
            {
                string commandline = info.get_commandline();
                if(commandline != null)
                {
                    for (int i = 0; i < commandline.length; i++)
                    {
                        if(commandline[i] == ' ' && commandline[i] == '%')
                            commandline = commandline.substring(0, i);
                    }

                    commandline = Path.get_basename(commandline);
                    string process_full_cmd = cmdline + " " + cmdline_parameter;
                    if(commandline == process_full_cmd)
                        app_info = info;
                    else if(commandline.contains("google-" + cmdline + "-")) //Fix for Google Chrome naming
                        app_info = info;

                    if(app_info == null)
                    {
                        commandline = info.get_commandline();
                        for (int i = 0; i < commandline.length; i++)
                        {
                            if(commandline[i] == ' ')
                                commandline = commandline.substring(0, i);
                        }

                        if(info.get_commandline().has_prefix(commandline + " " + commandline + "://")) //Fix for Steam naming
                            commandline = info.get_commandline();

                        commandline = Path.get_basename(commandline);
                        if(commandline == cmdline)
                            app_info = info;
                    }
                }
            }

            if(app_info != null)
                return app_info.get_display_name();
            else
                return cmdline;
        }

        private async void load_user_account() {
            try {
                Fdo.Accounts accounts = yield Bus.get_proxy (BusType.SYSTEM,
                                                             "org.freedesktop.Accounts",
                                                             "/org/freedesktop/Accounts");
                var user_account_path = yield accounts.FindUserById ((int64) representative_uid);
                user = yield Bus.get_proxy (BusType.SYSTEM,
                                                 "org.freedesktop.Accounts",
                                                 user_account_path);
            } catch (Error e) {
                warning ("Unable to obtain user account: %s", e.message);
            }
        }
    }
}