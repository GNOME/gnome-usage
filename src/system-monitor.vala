using Posix;

namespace Usage
{
    public class SystemMonitor : Object
    {
        public signal void cpu_processes_ready();
        public double cpu_load { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public double ram_usage { get; private set; }
        public double swap_usage { get; private set; }
        public uint64 net_download_actual { get; private set; }
        public uint64 net_upload_actual { get; private set; }
        public uint64 net_usage_actual { get; private set; }
        public uint64 net_download { get; private set; }
        public uint64 net_upload { get; private set; }
        public uint64 net_usage { get; private set; }

        private CpuMonitor cpu_monitor;
        private MemoryMonitor memory_monitor;
        private NetworkMonitor network_monitor;

        private HashTable<pid_t?, Process> process_table_pid;
        private HashTable<string, Process> cpu_process_table;
        private HashTable<string, Process> ram_process_table;
        private HashTable<string, Process> net_process_table;

		private int process_mode = GTop.KERN_PROC_UID;

		public enum ProcessMode
        {
		    ALL,
  			USER,
  			EXCLUDE_IDLE
		}

		public List<unowned Process> get_processes_pid()
        {
            return process_table_pid.get_values();
        }

        public unowned Process get_process_by_pid(pid_t pid)
        {
            return process_table_pid.get(pid);
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

        public List<unowned Process> get_net_processes()
        {
            return net_process_table.get_values();
        }

        public unowned Process get_net_process(string cmdline)
        {
            return net_process_table[cmdline];
        }

        public SystemMonitor()
        {
            GTop.init();

            cpu_monitor = new CpuMonitor();
            memory_monitor = new MemoryMonitor();
            network_monitor = new NetworkMonitor();

            process_table_pid = new HashTable<pid_t?, Process>(int_hash, int_equal);
            cpu_process_table = new HashTable<string, Process>(str_hash, str_equal);
            ram_process_table = new HashTable<string, Process>(str_hash, str_equal);
            net_process_table = new HashTable<string, Process>(str_hash, str_equal);

            var settings = (GLib.Application.get_default() as Application).settings;

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
            network_monitor.update();

            cpu_load = cpu_monitor.get_cpu_load();
            x_cpu_load = cpu_monitor.get_x_cpu_load();
            ram_usage = memory_monitor.get_ram_usage();
            swap_usage = memory_monitor.get_swap_usage();
            net_download_actual = network_monitor.get_net_download_actual();
            net_upload_actual = network_monitor.get_net_upload_actual();
            net_usage_actual = network_monitor.get_net_usage_actual();
            net_download = network_monitor.get_net_download();
            net_upload = network_monitor.get_net_upload();
            net_usage = network_monitor.get_net_usage();

            foreach(unowned Process process in process_table_pid.get_values())
            {
                process.alive = false;
            }

            set_alive_false_table_cmdline(ref cpu_process_table);
            set_alive_false_table_cmdline(ref ram_process_table);
            set_alive_false_table_cmdline(ref net_process_table);

            var uid = Posix.getuid();
            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode, uid);

            for(uint i = 0; i < proclist.number; i++)
            {
                if (!(pids[i] in process_table_pid))
                {
                    var process = new Process();
                    process.pid = pids[i];
                    process.alive = true;
                    process.cmdline = get_full_process_cmd_for_pid (pids[i], out process.cmdline_parameter);
                    process.mem_usage = 0;
                    process.mem_usage_percentages = 0;
                    cpu_monitor.get_cpu_info_for_pid(pids[i], ref process.last_processor, ref process.cpu_load, ref process.cpu_last_used, ref process.x_cpu_last_used);
                    process.cpu_load = 0;
                    process.x_cpu_load = 0;
                    process.net_download = 0;
                    process.net_upload = 0;
                    process.net_all = 0;
                    process_table_pid.insert (pids[i], (owned) process);
                }
                else
                {
                    unowned Process process = process_table_pid[pids[i]];
                    process.alive = true;
                    cpu_monitor.get_cpu_info_for_pid(pids[i], ref process.last_processor, ref process.cpu_load, ref process.cpu_last_used, ref process.x_cpu_last_used);
                    memory_monitor.get_memory_info_for_pid(pids[i], ref process.mem_usage, ref process.mem_usage_percentages);
                    network_monitor.get_network_info_for_pid(pids[i], ref process.net_download, ref process.net_upload, ref process.net_all);
                }
            }

            foreach(unowned Process process in process_table_pid.get_values())
            {
                if (process.alive == false)
                    process_table_pid.remove (process.pid);
            }

            var process_table_pid_condition = new HashTable<pid_t?, Process>(int_hash, int_equal);
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.cpu_load >= 1)
                    process_table_pid_condition.insert(process.pid, process);
            }
            get_updates_table_cmdline(process_table_pid_condition, ref cpu_process_table);

            process_table_pid_condition.remove_all();
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.mem_usage >= 1)
                    process_table_pid_condition.insert(process.pid, process);
            }
            get_updates_table_cmdline(process_table_pid_condition, ref ram_process_table);

            process_table_pid_condition.remove_all();
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.net_all >= 1)
                    process_table_pid_condition.insert(process.pid, process);
            }
            get_updates_table_cmdline(process_table_pid_condition, ref net_process_table);

            return true;
        }

        public void set_process_mode(ProcessMode mode)
        {
		    switch(mode)
  			{
        		case ProcessMode.ALL:
					process_mode = GTop.KERN_PROC_ALL;
					break;
				case ProcessMode.USER:
					process_mode = GTop.KERN_PROC_UID;
					break;
				case ProcessMode.EXCLUDE_IDLE:
					process_mode = GTop.EXCLUDE_IDLE;
					break;
			  }
		}

		private string get_full_process_cmd_for_pid (pid_t pid, out string cmd_parameter)
        {
            GTop.ProcArgs proc_args;
            GTop.ProcState proc_state;
            var args = GTop.get_proc_argv (out proc_args, pid);
            GTop.get_proc_state (out proc_state, pid);
            string cmd = (string) proc_state.cmd;
            cmd_parameter = "";

            var secure_arguments = new string[2];

            for(int i = 0; i < 2; i++)
            {
                if(args[i] != null)
                {
                    secure_arguments[i] = args[i];
                    for (int j = 0; j < args[i].length; j++)
                    {
                        if(args[i][j] == ' ')
                            secure_arguments[i] = args[i].substring(0, j);
                    }
                }
                else
                    secure_arguments[i] = "";
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

        private void set_alive_false_table_cmdline(ref HashTable<string, Process> process_table_cmdline)
        {
            foreach(unowned Process process in process_table_cmdline.get_values())
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

        private void get_updates_table_cmdline(HashTable<pid_t?, Process> from_table, ref HashTable<string, Process> to_table)
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
                            process.last_processor = process_it.last_processor;
                            process.cpu_load = process_it.cpu_load;
                            process.x_cpu_load = process_it.x_cpu_load;
                            process.alive = process_it.alive;
                            process.cpu_last_used = process_it.cpu_last_used;
                            process.x_cpu_last_used = process_it.x_cpu_last_used;
                            process.mem_usage = process_it.mem_usage;
                            process.net_download = process_it.net_download;
                            process.net_upload = process_it.net_upload;
                            process.net_all = process_it.net_all;
                        }
                        else //add subrow
                        {
                            var process = new Process();
                            process.pid = process_it.pid;
                            process.alive = process_it.alive;
                            process.cmdline = process_it.cmdline;
                            process.cmdline_parameter = process_it.cmdline_parameter;
                            process.last_processor = process_it.last_processor;
                            process.cpu_load = process_it.cpu_load;
                            process.x_cpu_load = process_it.x_cpu_load ;
                            process.cpu_last_used = process_it.cpu_last_used;
                            process.x_cpu_last_used = process_it.x_cpu_last_used;
                            process.mem_usage = process_it.mem_usage;
                            process.net_download = process_it.net_download;
                            process.net_upload = process_it.net_upload;
                            process.net_all = process_it.net_all;
                            to_table[process_it.cmdline].sub_processes.insert(process_it.pid, (owned) process);
                        }
                    }
                    else //update process or transform to group and add subrow
                    {
                        if(process_it.pid == to_table[process_it.cmdline].pid) //update process
                        {
                            unowned Process process = to_table[process_it.cmdline];
                            process.last_processor = process_it.last_processor;
                            process.cpu_load = process_it.cpu_load;
                            process.x_cpu_load = process_it.x_cpu_load ;
                            process.alive = process_it.alive;
                            process.cpu_last_used = process_it.cpu_last_used;
                            process.x_cpu_last_used = process_it.x_cpu_last_used;
                            process.mem_usage = process_it.mem_usage;
                            process.net_download = process_it.net_download;
                            process.net_upload = process_it.net_upload;
                            process.net_all = process_it.net_all;
                        }
                        else //transform to group and add subrow
                        {
                            to_table[process_it.cmdline].sub_processes = new HashTable<pid_t?, Process>(int_hash, int_equal);
                            unowned Process process = to_table[process_it.cmdline];

                            var sub_process_one = new Process();
                            sub_process_one.pid = process_it.pid;
                            sub_process_one.alive = process.alive;
                            sub_process_one.cmdline = process.cmdline;
                            sub_process_one.cmdline_parameter = process.cmdline_parameter;
                            sub_process_one.last_processor = process.last_processor;
                            sub_process_one.cpu_load = process.cpu_load;
                            sub_process_one.x_cpu_load = process.x_cpu_load;
                            sub_process_one.cpu_last_used = process.cpu_last_used;
                            sub_process_one.x_cpu_last_used = process.x_cpu_last_used;
                            sub_process_one.mem_usage = process.mem_usage;
                            sub_process_one.net_download = process.net_download;
                            sub_process_one.net_upload = process.net_upload;
                            sub_process_one.net_all = process.net_all;
                            to_table[process_it.cmdline].sub_processes.insert(sub_process_one.pid, (owned) sub_process_one);
                            process.cmdline_parameter = "";

                            var sub_process = new Process();
                            sub_process.pid = process_it.pid;
                            sub_process.alive = process_it.alive;
                            sub_process.cmdline = process_it.cmdline;
                            sub_process.cmdline_parameter = process_it.cmdline_parameter;
                            sub_process.last_processor = process_it.last_processor;
                            sub_process.cpu_load = process_it.cpu_load;
                            sub_process.x_cpu_load = process_it.x_cpu_load;
                            sub_process.cpu_last_used = process_it.cpu_last_used;
                            sub_process.x_cpu_last_used = process_it.x_cpu_last_used;
                            sub_process.mem_usage = process_it.mem_usage;
                            sub_process.net_download = process_it.net_download;
                            sub_process.net_upload = process_it.net_upload;
                            sub_process.net_all = process_it.net_all;
                            to_table[process_it.cmdline].sub_processes.insert(process_it.pid, (owned) sub_process);
                        }
                    }
                }
                else //add process
                {
                     var process = new Process();
                     process.pid = process_it.pid;
                     process.alive = process_it.alive;
                     process.cmdline = process_it.cmdline;
                     process.cmdline_parameter = process_it.cmdline_parameter;
                     process.last_processor = process_it.last_processor;
                     process.cpu_load = process_it.cpu_load;
                     process.x_cpu_load = process_it.x_cpu_load;
                     process.cpu_last_used = process_it.cpu_last_used;
                     process.x_cpu_last_used = process_it.x_cpu_last_used;
                     process.mem_usage = process_it.mem_usage;
                     process.net_download = process_it.net_download;
                     process.net_upload = process_it.net_upload;
                     process.net_all = process_it.net_all;
                     to_table.insert(process.cmdline, (owned) process);
                }
            }

            foreach(unowned Process process in to_table.get_values())
            {
                if(process.sub_processes == null)
                {
                    if(process.alive == false)
                        to_table.remove (process.cmdline);
                }
                else
                {
                    double cpu_load = 0;
                    uint64 mem_usage = 0;
                    uint64 net_all = 0;
                    uint64 net_download = 0;
                    uint64 net_upload = 0;
                    foreach(unowned Process sub_process in process.sub_processes.get_values())
                    {
                        if (sub_process.alive == false)
                            process.sub_processes.remove(sub_process.pid);

                        cpu_load += sub_process.cpu_load;
                        mem_usage += sub_process.mem_usage;
                        net_all += sub_process.net_all;
                        net_download += sub_process.net_download;
                        net_upload += sub_process.net_upload;
                    }
                    process.cpu_load = cpu_load;
                    process.mem_usage = mem_usage;
                    process.net_all = net_all;
                    process.net_download = net_download;
                    process.net_upload = net_upload;

                    if(process.sub_processes.size() == 1) //tranform to process
                    {
                        foreach(unowned Process sub_process in process.sub_processes.get_values()) //only one
                        {
                            process.pid = sub_process.pid;
                            process.alive = sub_process.alive;
                            process.cmdline = sub_process.cmdline;
                            process.cmdline_parameter = sub_process.cmdline_parameter;
                            process.last_processor = sub_process.last_processor;
                            process.cpu_load = sub_process.cpu_load;
                            process.x_cpu_load = sub_process.x_cpu_load;
                            process.cpu_last_used = sub_process.cpu_last_used;
                            process.x_cpu_last_used = sub_process.x_cpu_last_used;
                            process.mem_usage = sub_process.mem_usage;
                            process.net_download = sub_process.net_download;
                            process.net_upload = sub_process.net_upload;
                            process.net_all = sub_process.net_all;
                            process.sub_processes.remove(sub_process.pid);
                            process.sub_processes = null;
                        }
                    }
                    else if(process.sub_processes.size() == 0)
                    {
                        process.sub_processes = null;
                        process.alive = false;
                        to_table.remove(process.cmdline);
                    }
                }
            }
        }
    }
}
