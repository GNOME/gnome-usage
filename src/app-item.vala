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
        public bool gamemode {get; private set; }

        private static HashTable<string, AppInfo>? apps_info;
        private AppInfo? app_info = null;

        public static void init() {
            apps_info = new HashTable<string, AppInfo>(str_hash, str_equal);
            var _apps_info = AppInfo.get_all();

            foreach (AppInfo info in _apps_info) {
                string cmd = info.get_commandline();
                if (cmd == null)
                    continue;

                sanitize_cmd (ref cmd);
                apps_info.insert(cmd, info);
            }
        }

        public static bool have_app_info(string cmdline) {
            return apps_info.get(cmdline) != null;
        }

        public AppItem(Process process) {
            app_info = apps_info.get(process.cmdline);
            representative_cmdline = process.cmdline;
            representative_uid = process.uid;
            display_name = find_display_name();
            processes.insert(process.pid, process);
            load_user_account.begin();
            gamemode = process.gamemode;
        }

        public AppItem.system() {
            display_name = _("System");
            representative_cmdline = "system";
        }

        construct {
            processes = new HashTable<Pid?, Process>(int_hash, int_equal);
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
            int games = 0;

            foreach(var process in processes.get_values()) {
                if(!process.mark_as_updated)
                    processes.remove(process.pid);
                else {
                    cpu_load += process.cpu_load;
                    mem_usage += process.mem_usage;
                }
                if(process.gamemode)
                    games++;
            }

            gamemode = games > 0;
            cpu_load = double.min(100, cpu_load);
        }

        public void remove_process(Process process) {
            processes.remove(process.pid);
        }

        public void replace_process(Process process) {
            processes.replace(process.pid, process);
        }

        private string find_display_name() {
            if(app_info != null)
                return app_info.get_display_name();
            else
                return representative_cmdline;
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

        private static void sanitize_cmd(ref string? commandline) {
            if (commandline == null)
                return;

            // flatpak: parse the command line of the containerized program
            if (commandline.contains("flatpak run")) {
                var index = commandline.index_of ("--command=") + 10;
                commandline = commandline.substring (index);
            }

            // TODO: unify this with the logic in get_full_process_cmd
            commandline = Process.first_component (commandline);
            commandline = Path.get_basename (commandline);
            commandline = Process.sanitize_name (commandline);

            // Workaround for google-chrome
            if (commandline.contains ("google-chrome-stable"))
                commandline = "chrome";
        }
    }
}