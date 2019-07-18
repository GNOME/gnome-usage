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

namespace Usage
{
    public class SystemMonitor : Object
    {
        public bool process_list_ready { get; private set; default = false; }
        public double cpu_load { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public uint64 ram_usage { get; private set; }
        public uint64 ram_total { get; private set; }
        public uint64 swap_usage { get; private set; }
        public uint64 swap_total { get; private set; }
        public bool group_system_apps { get; set; default = true; }

        private CpuMonitor cpu_monitor;
        private MemoryMonitor memory_monitor;
        private GameMode.PidList gamemode_pids;

        private HashTable<string, AppItem> app_table;
        private int process_mode = GTop.KERN_PROC_ALL;
        private static SystemMonitor system_monitor;

        public static SystemMonitor get_default()
        {
            if (system_monitor == null)
                system_monitor = new SystemMonitor ();

            return system_monitor;
        }

        public List<unowned AppItem> get_apps()
        {
            return app_table.get_values();
        }

        public unowned AppItem get_app_by_name(string name)
        {
            return app_table.get(name);
        }

        public SystemMonitor()
        {
            GTop.init();
            AppItem.init();

            cpu_monitor = new CpuMonitor();
            memory_monitor = new MemoryMonitor();
            gamemode_pids = new GameMode.PidList();

            app_table = new HashTable<string, AppItem>(str_hash, str_equal);
            var settings = Settings.get_default();

            init();
            this.notify["group-system-apps"].connect ((sender, property) => {
                init();
            });

            Timeout.add(settings.data_update_interval, update_data);
        }

        private void init()
        {
            var settings = Settings.get_default();
            app_table.remove_all();
            process_list_ready = false;

            if(group_system_apps) {
                var system = new AppItem.system();
                app_table.insert("system" , system);
            }

            update_data();
            Timeout.add(settings.data_update_interval, () =>
            {
                process_list_ready = true;
                return false;
            });
        }

        private bool update_data()
        {
            cpu_monitor.update();
            memory_monitor.update();

            cpu_load = cpu_monitor.get_cpu_load();
            x_cpu_load = cpu_monitor.get_x_cpu_load();
            ram_usage = memory_monitor.get_ram_usage();
            ram_total = memory_monitor.get_ram_total();
            swap_usage = memory_monitor.get_swap_usage();
            swap_total = memory_monitor.get_swap_total();

            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode);

            foreach(var app in app_table.get_values())
                app.mark_as_not_updated();

            for(uint i = 0; i < proclist.number; i++)
            {
                string cmd = get_full_process_cmd(pids[i]);
                string app_id = cmd;

                if(group_system_apps && is_system_app(cmd))
                    app_id = "system";

                if (!(app_id in app_table))
                {
                    var process = new Process(pids[i], cmd);
                    update_process(ref process);
                    var app = new AppItem(process);
                    app_table.insert (app_id, (owned) app);
                }
                else
                {
                    AppItem app = app_table[app_id];

                    if (!app.contains_process(pids[i]))
                    {
                        var process = new Process(pids[i], cmd);
                        update_process(ref process);
                        app.insert_process(process);
                    }
                    else
                    {
                        var process = app.get_process_by_pid(pids[i]);
                        update_process(ref process);
                        app.replace_process(process);
                    }
                }
            }

            foreach(var app in app_table.get_values())
                app.remove_processes();

            return true;
        }

        private void update_process(ref Process process)
        {
            cpu_monitor.update_process(ref process);
            memory_monitor.update_process(ref process);
            process.update_status();
            process.gamemode = gamemode_pids.contains((int) process.pid);
        }

        private string? sanitize_name (string name) {
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

        private string get_full_process_cmd (Pid pid)
        {
            GTop.ProcArgs proc_args;
            GTop.ProcState proc_state;
            string[] args = GTop.get_proc_argv (out proc_args, pid, 0);
            GTop.get_proc_state (out proc_state, pid);
            string cmd = (string) proc_state.cmd;
            string cmd_parameter = "";

            var secure_arguments = new string[2];

            for(int i = 0; i < 2; i++)
            {
                if(args[i] != null)
                {
                    secure_arguments[i] = args[i];
                }
                else
                {
                    secure_arguments[i] = "";
                    if (i == 0)
                        secure_arguments[1] = "";
                    break;
                }
            }

            for (int i = 0; i < secure_arguments.length; i++)
            {
                var name = Path.get_basename(secure_arguments[i]);

                if (name.has_prefix(cmd))
                {
                    for (int j = 0; j < name.length; j++)
                    {
                        if(name[j] == ' ')
                            name = name.substring(0, j);
                    }
                    if(i == 0)
                        cmd_parameter = secure_arguments[1];
                    else
                        cmd_parameter = secure_arguments[0];

                    return sanitize_name(name);
                }
            }

            return sanitize_name(cmd);
        }

        private bool is_system_app(string cmdline)
        {
            return !AppItem.have_app_info(cmdline);
        }
    }
}
