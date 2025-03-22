/* app-item.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
 * Copyright (C) 2023–2024 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.AppItem : Object {
    private static Icon default_icon = new GLib.ThemedIcon ("system-run-symbolic");

    public HashTable<Pid?, Process>? processes { get; set; }
    public string display_name { get; private set; }
    public string representative_cmdline { get; private set; }
    public uint representative_uid { get; private set; }
    public double cpu_load { get; private set; }
    public uint64 mem_usage { get; private set; }
    public Fdo.AccountsUser? user { get; private set; default = null; }
    public bool gamemode {get; private set; }
    public bool is_background { get; set; }
    public virtual bool running {
        get {
            return processes.length > 0;
        }
    }
    public virtual Icon icon {
        get {
            if (app_info == null || app_info.get_icon () == null) {
                return default_icon;
            }
            return app_info.get_icon ();
        }
    }
    public virtual string? container {
        get {
            if ((this.app_info as DesktopAppInfo)?.get_categories () == "X-WayDroid-App;") {
                return "Waydroid";
            }
            return null;
        }
    }

    private static HashTable<Process, AppItem> app_for_process;
    private static HashTable<string, AppInfo> apps_info;
    private static HashTable<string, AppInfo> appid_map;
    private AppInfo? app_info = null;

    public static void init () {
        app_for_process = new HashTable<Process, AppItem> (int_hash, int_equal);
        apps_info = new HashTable<string, AppInfo> (str_hash, str_equal);
        appid_map = new HashTable<string, AppInfo> (str_hash, str_equal);

        var _apps_info = AppInfo.get_all ();

        foreach (AppInfo info in _apps_info) {
            GLib.DesktopAppInfo? dai = info as GLib.DesktopAppInfo;
            string? id = null;

            id = dai?.get_string ("X-Flatpak");
            if (id != null) {
                /* prioritise app infos without nodisplay */
                if (appid_map[(!) id] == null || !((!) dai).get_nodisplay ()) {
                    appid_map.insert ((!) id, info);
                }
            }

            if (id == null) {
                id = info.get_id ();

                if (id?.has_suffix (".desktop") ?? false) {
                    id = id?.substring (0, id?.length - 8);
                }
                if (dai?.get_categories () == "X-WayDroid-App;") {
                    if (id == "Waydroid") {
                        apps_info.insert ("waydroid", info);
                        id = "system_waydroid";
                    } else {
                        id = id?.substring (9);
                    }
                }

                if (id != null) {
                    appid_map.insert ((!) id, info);
                }
            }

            string? cmd = info.get_commandline ();

            if (cmd == null)
                continue;

            sanitize_cmd (ref cmd);
            if (apps_info[(!) cmd] == null) {
                apps_info.insert ((!) cmd, info);
            }
        }
    }

    public static string? appid_from_unit (string ?systemd_unit) {
        string ?escaped_id = null;
        string ?id = null;

        if (systemd_unit == null)
            return null;

        /* This is gnome-launched-APPID.desktop-RAND.scope */
        if (systemd_unit.has_prefix ("gnome-launched-")) {
            int index = -1;

            index = systemd_unit.index_of (".desktop-");
            // This is just argv[0] name encoded, we could also decode it
            // and look it up differently.
            // There is no standardization though for such a scheme.
            if (index == -1)
                return null;

            return systemd_unit[15:index];
        }

        /* In other cases, assume compliance with spec, i.e. for
         * .scope units we fetch the second to last dashed item,
         * for .service units the last (as they use @ to separate
         * any required) */
        string[] segments = systemd_unit.split ("-");

        if (systemd_unit.has_suffix (".scope") && segments.length >= 2) {
            escaped_id = segments[segments.length - 2];
        } else if (systemd_unit.has_suffix (".service") && segments.length >= 1) {
            string tmp = segments[segments.length - 1];
            /* Strip .service */
            tmp = tmp[0:tmp.length-8];
            /* Remove any @ element (if there) */
            escaped_id = tmp.split ("@", 2)[0];
        }

        if (escaped_id == null)
            return null;

        /* Now, unescape any \xXX escapes, which should only be dashes
         * from the reverse domain name. */
        id = Utils.unescape (escaped_id);
        if (id == null)
            return null;

        return id;
    }

    public static AppItem? app_item_for_process (Process process) {
        return app_for_process.@get (process);
    }

    public static AppInfo? app_info_for_process (Process p) {
        AppInfo? info = null;
        string? cgroup = p.cgroup;

        /* Waydroid */
        if (cgroup == "/lxc.payload.waydroid") {
            return appid_map[p.cmdline] ?? appid_map["system_waydroid"];
        }

        if (cgroup != null) {
            /* Try to extract an application ID, this is a bit "magic".
             * See https://systemd.io/DESKTOP_ENVIRONMENTS/
             * and we also have some special cases for GNOME which is not
             * currently compliant to the specification. */
            string? systemd_unit = null;
            string? appid = null;
            string[] components;

            components = cgroup?.split ("/");
            systemd_unit = components[components.length - 1];
            appid = appid_from_unit (systemd_unit);
            if (appid != null)
                info = appid_map[(!) appid];
        }

        if (info == null && p.cmdline != null)
            info = apps_info[p.cmdline];

        if (info == null && p.app_id != null)
            info = appid_map[(!) p.app_id];

        return info;
    }

    public AppItem (Process process) {
        app_info = app_info_for_process (process);
        representative_cmdline = process.cmdline;
        representative_uid = process.uid;
        display_name = find_display_name ();
        this.insert_process (process);
        load_user_account.begin ();
        gamemode = process.gamemode;
    }

    public AppItem.system () {
        display_name = _("System");
        representative_cmdline = "system";
    }

    construct {
        processes = new HashTable<Pid?, Process>(int_hash, int_equal);
    }

    public bool is_running () {
        return this.running;
    }

    public bool contains_process (Pid pid) {
        return processes.contains (pid);
    }

    public Process get_process_by_pid (Pid pid) {
        return processes.@get (pid);
    }

    public void insert_process (Process process) {
        app_for_process.insert (process, this);
        processes.insert (process.pid, process);
        this.notify_property ("running");
    }

    public bool is_killable () {
        bool blocked = this.representative_cmdline in Settings.get_default ().get_strv ("unkillable-processes");
        bool by_current_user = this.user?.Uid == Posix.geteuid ();
        return !blocked && by_current_user;
    }

    public void kill (Posix.Signal? sig = Posix.Signal.TERM) {
        if (this.is_killable ()) {
            foreach (var process in processes.get_values ()) {
                debug ("Terminating %d", (int) process.pid);
                Posix.kill (process.pid, sig ?? Posix.Signal.TERM);
            }
        }
    }

    public void mark_as_not_updated () {
        foreach (var process in processes.get_values ())
            process.mark_as_updated = false;
    }

    public void remove_processes () {
        double cpu_load = 0;
        uint64 mem_usage = 0;
        bool gamemode = false;

        foreach (var process in processes.get_values ()) {
            if (!process.mark_as_updated) {
                this.remove_process (process);
            } else {
                cpu_load += process.cpu_load;
                mem_usage += process.mem_usage;
                if (process.gamemode) {
                    gamemode = true;
                }
            }
        }

        this.cpu_load = cpu_load;
        this.mem_usage = mem_usage;
        this.gamemode = gamemode;
    }

    public void remove_process (Process process) {
        app_for_process.remove (process);
        processes.remove (process.pid);
        this.notify_property ("running");
    }

    public void replace_process (Process process) {
        app_for_process.remove (this.get_process_by_pid (process.pid));
        app_for_process.insert (process, this);
        processes.replace (process.pid, process);
        this.notify_property ("running");
    }

    private string find_display_name () {
        if (app_info != null)
            return app_info.get_display_name ();
        else
            return representative_cmdline;
    }

    private async void load_user_account () {
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

    private static void sanitize_cmd (ref string? commandline) {
        if (commandline == null)
            return;

        // flatpak: parse the command line of the containerized program
        if (commandline.contains ("flatpak run")) {
            var index = commandline.index_of ("--command=") + 10;
            commandline = commandline.substring (index);
        }

        if (commandline.contains ("waydroid app launch ")) {
            commandline = commandline.substring (20);
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
