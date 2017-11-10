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
        public signal void cpu_processes_ready();
        public double cpu_load { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public uint64 ram_usage { get; private set; }
        public uint64 ram_total { get; private set; }
        public uint64 swap_usage { get; private set; }
        public uint64 swap_total { get; private set; }

        private CpuMonitor cpu_monitor;
        private MemoryMonitor memory_monitor;

        private HashTable<Pid?, Process> process_table;
        private HashTable<string, Process> cpu_process_table;
        private HashTable<string, Process> ram_process_table;

        private int process_mode = GTop.EXCLUDE_SYSTEM;
        private GLib.List<AppInfo> apps_info;

        private static SystemMonitor system_monitor;

        public static SystemMonitor get_default()
        {
            if (system_monitor == null)
                system_monitor = new SystemMonitor ();

            return system_monitor;
        }

        public List<unowned Process> get_processes()
        {
            return process_table.get_values();
        }

        public unowned Process get_process_by_pid(Pid pid)
        {
            return process_table.get(pid);
        }

        public List<unowned Process> get_cpu_processes()
        {
            return cpu_process_table.get_values();
        }

        public unowned Process get_cpu_process(string cmdline)
        {
            return cpu_process_table[cmdline];
        }

        public List<unowned Process> get_ram_processes()
        {
            return ram_process_table.get_values();
        }

        public unowned Process get_ram_process(string cmdline)
        {
            return ram_process_table[cmdline];
        }

        public unowned GLib.List<AppInfo> get_apps_info()
        {
            return apps_info;
        }

        public SystemMonitor()
        {
            GTop.init();

            cpu_monitor = new CpuMonitor();
            memory_monitor = new MemoryMonitor();

            process_table = new HashTable<Pid?, Process>(int_hash, int_equal);
            cpu_process_table = new HashTable<string, Process>(str_hash, str_equal);
            ram_process_table = new HashTable<string, Process>(str_hash, str_equal);

            var settings = Settings.get_default();
            apps_info = AppInfo.get_all();

            update_data();
            Timeout.add(settings.data_update_interval, update_data);
            Timeout.add(settings.data_update_interval, () =>
            {
                cpu_processes_ready();
                return false;
            });
        }

		public bool update_data()
        {
            cpu_monitor.update();
            memory_monitor.update();

            cpu_load = cpu_monitor.get_cpu_load();
            x_cpu_load = cpu_monitor.get_x_cpu_load();
            ram_usage = memory_monitor.get_ram_usage();
            ram_total = memory_monitor.get_ram_total();
            swap_usage = memory_monitor.get_swap_usage();
            swap_total = memory_monitor.get_swap_total();

            foreach(unowned Process process in process_table.get_values())
            {
                process.alive = false;
            }

            set_alive_false(ref cpu_process_table);
            set_alive_false(ref ram_process_table);

            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode);

            for(uint i = 0; i < proclist.number; i++)
            {
                if (!(pids[i] in process_table))
                {
                    string cmdline_parameter;
                    string cmdline = get_full_process_cmd(pids[i], out cmdline_parameter);
                    string display_name = get_display_name(cmdline, cmdline_parameter);
                    User user = get_user(pids[i]);
                    var process = new Process(pids[i], cmdline, cmdline_parameter, display_name, user);
                    cpu_monitor.update_process(ref process);
                    process_table.insert (pids[i], (owned) process);
                }
                else
                {
                    Process process = process_table[pids[i]];
                    process.alive = true;
                    update_process_status(ref process);
                    cpu_monitor.update_process(ref process);
                    memory_monitor.update_process(ref process);
                }
            }

            foreach(unowned Process process in process_table.get_values())
            {
                if (!process.alive)
                {
                    process.status = ProcessStatus.DEAD;
                    process_table.remove (process.pid);
                }
            }

            var process_table_temp = new HashTable<Pid?, Process>(int_hash, int_equal);
            foreach(unowned Process process in process_table.get_values())
            {
                if(process.cpu_load >= 1)
                    process_table_temp.insert(process.pid, process);
            }
            update_processes(process_table_temp, ref cpu_process_table);

            process_table_temp.remove_all();
            foreach(unowned Process process in process_table.get_values())
            {
                if(process.mem_usage >= 1)
                    process_table_temp.insert(process.pid, process);
            }
            update_processes(process_table_temp, ref ram_process_table);

            return true;
        }

    private User get_user(Pid pid)
    {
            GTop.ProcUid procUid;
            GTop.get_proc_uid(out procUid, pid);
            Act.User user = Act.UserManager.get_default().get_user_by_id(procUid.uid);
            return new User(user.get_uid(), user.get_real_name(), user.is_local_account());
    }

		private string get_display_name(string cmdline, string cmdline_parameter)
		{
            AppInfo app_info = null;
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

		private string get_full_process_cmd (Pid pid, out string cmd_parameter)
        {
            GTop.ProcArgs proc_args;
            GTop.ProcState proc_state;
            string[] args = GTop.get_proc_argv (out proc_args, pid, 0);
            GTop.get_proc_state (out proc_state, pid);
            string cmd = (string) proc_state.cmd;
            cmd_parameter = "";

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

                    return name;
                }
            }

            return cmd;
        }

        private void update_process_status (ref Process process)
        {
            GTop.ProcState proc_state;
            GTop.get_proc_state (out proc_state, process.pid);

            switch(proc_state.state)
            {
                case GTop.PROCESS_RUNNING:
                case GTop.PROCESS_UNINTERRUPTIBLE:
                    process.status = ProcessStatus.RUNNING;
                    break;
                case GTop.PROCESS_SWAPPING:
                case GTop.PROCESS_INTERRUPTIBLE:
                case GTop.PROCESS_STOPPED:
                    process.status = ProcessStatus.SLEEPING;
                    break;
                case GTop.PROCESS_DEAD:
                case GTop.PROCESS_ZOMBIE:
                default:
                    process.status = ProcessStatus.DEAD;
                    break;
            }

            if(process.cpu_load > 0)
                process.status = ProcessStatus.RUNNING;
        }

        private void set_alive_false(ref HashTable<string, Process> process_table)
        {
            foreach(unowned Process process in process_table.get_values())
            {
                if(process.sub_processes == null)
                    process.alive = false;
                else
                {
                    foreach(unowned Process sub_process in process.sub_processes.get_values())
                    {
                        sub_process.alive = false;
                    }
                }
            }
        }

        private void update_processes(HashTable<Pid?, Process> from_table, ref HashTable<string, Process> to_table)
        {
            foreach(unowned Process process_it in from_table.get_values())
            {
                if(process_it.cmdline in to_table) //subprocess or update process
                {
                    if(to_table[process_it.cmdline].sub_processes != null) //subprocess
                    {
                        if(process_it.pid in to_table[process_it.cmdline].sub_processes) //update subprocess
                        {
                            unowned Process process = to_table[process_it.cmdline].sub_processes[process_it.pid];
                            process.update_from_process(process_it);
                        }
                        else //add subrow
                        {
                            User user = get_user(process_it.pid);
                            var process = new Process(process_it.pid, process_it.cmdline, process_it.cmdline_parameter, process_it.display_name, user);
                            process.update_from_process(process_it);
                            to_table[process.cmdline].sub_processes.insert(process.pid, (owned) process);
                        }
                    }
                    else //update process or transform to group and add subrow
                    {
                        if(process_it.pid == to_table[process_it.cmdline].pid) //update process
                        {
                            unowned Process process = to_table[process_it.cmdline];
                            process.update_from_process(process_it);
                        }
                        else //transform to group and add subrow
                        {
                            to_table[process_it.cmdline].sub_processes = new HashTable<Pid?, Process>(int_hash, int_equal);
                            unowned Process process = to_table[process_it.cmdline];

                            User user = get_user(process.pid);
                            var sub_process_one = new Process(process.pid, process.cmdline, process.cmdline_parameter, process.display_name, user);
                            sub_process_one.update_from_process(process);
                            to_table[process_it.cmdline].sub_processes.insert(sub_process_one.pid, (owned) sub_process_one);

                            user = get_user(process_it.pid);
                            var sub_process = new Process(process_it.pid, process_it.cmdline, process_it.cmdline_parameter, process_it.display_name, user);
                            sub_process.update_from_process(process_it);
                            to_table[process_it.cmdline].sub_processes.insert(process_it.pid, (owned) sub_process);
                        }
                    }
                }
                else //add process
                {
                     User user = get_user(process_it.pid);
                     var process = new Process(process_it.pid, process_it.cmdline, process_it.cmdline_parameter, process_it.display_name, user);
                     process.update_from_process(process_it);
                     to_table.insert(process.cmdline, (owned) process);
                }
            }

            foreach(unowned Process process in to_table.get_values())
            {
                if(process.sub_processes == null)
                {
                    if(!process.alive)
                        to_table.remove (process.cmdline);
                }
                else
                {
                    double cpu_load = 0;
                    uint64 mem_usage = 0;
                    foreach(unowned Process sub_process in process.sub_processes.get_values())
                    {
                        if (!sub_process.alive)
                            process.sub_processes.remove(sub_process.pid);
                        else
                        {
                            cpu_load += sub_process.cpu_load;
                            mem_usage += sub_process.mem_usage;
                        }
                    }
                    process.cpu_load = cpu_load;
                    process.mem_usage = mem_usage;

                    if(process.sub_processes.length == 1) //tranform to process
                    {
                        foreach(unowned Process sub_process in process.sub_processes.get_values()) //only one
                        {
                            process.sub_processes = null;
                            process = sub_process;
                        }
                    }
                    else if(process.sub_processes.length == 0)
                    {
                        process.sub_processes = null;
                        process.alive = false;
                        process.status = ProcessStatus.DEAD;
                        to_table.remove(process.cmdline);
                    }
                }
            }
        }
    }
}
