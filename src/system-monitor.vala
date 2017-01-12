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
                process.set_alive(false);
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
                    string cmdline_parameter;
                    string cmdline = get_full_process_cmd_for_pid(pids[i], out cmdline_parameter);
                    var process = new Process(pids[i], cmdline, cmdline_parameter);
                    cpu_monitor.update_process_info(ref process);
                    process_table_pid.insert (pids[i], (owned) process);
                }
                else
                {
                    Process process = process_table_pid[pids[i]];
                    process.set_alive(true);
                    get_process_status(ref process);
                    cpu_monitor.update_process_info(ref process);
                    memory_monitor.update_process_info(ref process);
                    network_monitor.update_process_info(ref process);
                }
            }

            foreach(unowned Process process in process_table_pid.get_values())
            {
                if (process.get_alive() == false)
                {
                    process.set_status(ProcessStatus.DEAD);
                    process_table_pid.remove (process.get_pid());
                }
            }

            var process_table_pid_condition = new HashTable<pid_t?, Process>(int_hash, int_equal);
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.get_cpu_load() >= 1)
                    process_table_pid_condition.insert(process.get_pid(), process);
            }
            get_updates_table_cmdline(process_table_pid_condition, ref cpu_process_table);

            process_table_pid_condition.remove_all();
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.get_mem_usage() >= 1)
                    process_table_pid_condition.insert(process.get_pid(), process);
            }
            get_updates_table_cmdline(process_table_pid_condition, ref ram_process_table);

            process_table_pid_condition.remove_all();
            foreach(unowned Process process in process_table_pid.get_values())
            {
                if(process.get_net_all() >= 1)
                    process_table_pid_condition.insert(process.get_pid(), process);
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

        private void get_process_status (ref Process process)
        {
            GTop.ProcState proc_state;
            GTop.get_proc_state (out proc_state, process.get_pid());

            switch(proc_state.state)
            {
                case GTop.PROCESS_RUNNING:
                case GTop.PROCESS_UNINTERRUPTIBLE:
                    process.set_status(ProcessStatus.RUNNING);
                    break;
                case GTop.PROCESS_SWAPPING:
                case GTop.PROCESS_INTERRUPTIBLE:
                case GTop.PROCESS_STOPPED:
                    process.set_status(ProcessStatus.SLEEPING);
                    break;
                case GTop.PROCESS_DEAD:
                case GTop.PROCESS_ZOMBIE:
                default:
                    process.set_status(ProcessStatus.DEAD);
                    break;
            }

            if(process.get_cpu_load() > 0)
                process.set_status(ProcessStatus.RUNNING);
        }

        private void set_alive_false_table_cmdline(ref HashTable<string, Process> process_table_cmdline)
        {
            foreach(unowned Process process in process_table_cmdline.get_values())
            {
                if(process.get_sub_processes() == null)
                    process.set_alive(false);
                else
                {
                    foreach(unowned Process sub_process in process.get_sub_processes().get_values())
                    {
                        sub_process.set_alive(false);
                    }
                }
            }
        }

        private void get_updates_table_cmdline(HashTable<pid_t?, Process> from_table, ref HashTable<string, Process> to_table)
        {
            foreach(unowned Process process_it in from_table.get_values())
            {
                if(process_it.get_cmdline() in to_table) //subprocess or update process
                {
                    if(to_table[process_it.get_cmdline()].get_sub_processes() != null) //subprocess
                    {
                        if(process_it.get_pid() in to_table[process_it.get_cmdline()].get_sub_processes()) //update subprocess
                        {
                            unowned Process process = to_table[process_it.get_cmdline()].get_sub_processes()[process_it.get_pid()];
                            process.update_from_process(process_it);
                        }
                        else //add subrow
                        {
                            var process = new Process(process_it.get_pid(), process_it.get_cmdline(), process_it.get_cmdline_parameter());
                            process.update_from_process(process_it);
                            to_table[process.get_cmdline()].get_sub_processes().insert(process.get_pid(), (owned) process);
                        }
                    }
                    else //update process or transform to group and add subrow
                    {
                        if(process_it.get_pid() == to_table[process_it.get_cmdline()].get_pid()) //update process
                        {
                            unowned Process process = to_table[process_it.get_cmdline()];
                            process.update_from_process(process_it);
                        }
                        else //transform to group and add subrow
                        {
                            to_table[process_it.get_cmdline()].set_sub_processes(new HashTable<pid_t?, Process>(int_hash, int_equal));
                            unowned Process process = to_table[process_it.get_cmdline()];

                            var sub_process_one = new Process(process.get_pid(), process.get_cmdline(), process.get_cmdline_parameter());
                            sub_process_one.update_from_process(process);
                            to_table[process_it.get_cmdline()].get_sub_processes().insert(sub_process_one.get_pid(), (owned) sub_process_one);
                            process.set_cmdline_parameter("");

                            var sub_process = new Process(process_it.get_pid(), process_it.get_cmdline(), process_it.get_cmdline_parameter());
                            sub_process.update_from_process(process_it);
                            to_table[process_it.get_cmdline()].get_sub_processes().insert(process_it.get_pid(), (owned) sub_process);
                        }
                    }
                }
                else //add process
                {
                     var process = new Process(process_it.get_pid(), process_it.get_cmdline(), process_it.get_cmdline_parameter());
                     process.update_from_process(process_it);
                     to_table.insert(process.get_cmdline(), (owned) process);
                }
            }

            foreach(unowned Process process in to_table.get_values())
            {
                if(process.get_sub_processes() == null)
                {
                    if(process.get_alive() == false)
                        to_table.remove (process.get_cmdline());
                }
                else
                {
                    double cpu_load = 0;
                    uint64 mem_usage = 0;
                    uint64 net_all = 0;
                    uint64 net_download = 0;
                    uint64 net_upload = 0;
                    foreach(unowned Process sub_process in process.get_sub_processes().get_values())
                    {
                        if (sub_process.get_alive() == false)
                            process.get_sub_processes().remove(sub_process.get_pid());

                        cpu_load += sub_process.get_cpu_load();
                        mem_usage += sub_process.get_mem_usage();
                        net_all += sub_process.get_net_all();
                        net_download += sub_process.get_net_download();
                        net_upload += sub_process.get_net_upload();
                    }
                    process.set_cpu_load(cpu_load);
                    process.set_mem_usage(mem_usage);
                    process.set_net_all(net_all);
                    process.set_net_download(net_download);
                    process.set_net_upload(net_upload);

                    if(process.get_sub_processes().size() == 1) //tranform to process
                    {
                        foreach(unowned Process sub_process in process.get_sub_processes().get_values()) //only one
                        {
                            process = sub_process;
                            process.set_sub_processes(null);
                        }
                    }
                    else if(process.get_sub_processes().size() == 0)
                    {
                        process.set_sub_processes(null);
                        process.set_alive(false);
                        process.set_status(ProcessStatus.DEAD);
                        to_table.remove(process.get_cmdline());
                    }
                }
            }
        }
    }
}
