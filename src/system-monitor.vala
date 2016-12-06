using Posix;

namespace Usage
{
    [Compact]
    public class Process : Object
    {
        internal pid_t pid;
        internal string cmdline;
        internal double cpu_load;
        internal double x_cpu_load;
        internal uint64 cpu_last_used;
        internal uint64 x_cpu_last_used;
        internal uint last_processor;
        internal double mem_usage;
        internal HashTable<pid_t?, Process> sub_processes;
        internal bool alive;
    }

    public class SystemMonitor
    {
        public double cpu_load { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public double mem_usage { get; private set; }
        public double swap_usage { get; private set; }

        uint64 cpu_last_used = 0;
        uint64 cpu_last_total = 0;

        uint64[] x_cpu_last_used;
        uint64[] x_cpu_last_total;

        HashTable<string, Process> process_table_cmdline;
        HashTable<pid_t?, Process> process_table_pid;

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

        public List<unowned Process> get_processes_cmdline()
        {
            return process_table_cmdline.get_values();
        }

        public unowned Process get_process_by_cmdline(string cmdline)
        {
            return process_table_cmdline[cmdline];
        }

        public SystemMonitor()
        {
            GTop.init();

            x_cpu_load = new double[get_num_processors()];
            x_cpu_last_used = new uint64[get_num_processors()];
            x_cpu_last_total = new uint64[get_num_processors()];
            process_table_cmdline = new HashTable<string, Process>(str_hash, str_equal);
            process_table_cmdline = new HashTable<string, Process>(str_hash, str_equal);
            process_table_pid = new HashTable<pid_t?, Process>(int_hash, int_equal);

            var settings = (GLib.Application.get_default() as Application).settings;

            update_data();
            Timeout.add(settings.data_update_interval, update_data);
            Timeout.add(settings.first_data_update_interval, () => //First load
            {
                update_data();
                return false;
            });
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

		private string get_full_process_cmd (string cmd, string[] args)
        {
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

                    return name;
                }
            }

            return cmd;
        }

		public bool update_data()
        {
		    /* CPU */
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load = (((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100;

            var x_cpu_used = new uint64[get_num_processors()];
            for (int i = 0; i < x_cpu_load.length; i++)
            {
                x_cpu_used[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
                x_cpu_load[i] = (((double) (x_cpu_used[i] - x_cpu_last_used[i])) / (cpu_data.xcpu_total[i] - x_cpu_last_total[i])) * 100;
            }

            /* Memory */
            GTop.Mem mem;
            GTop.get_mem (out mem);
            mem_usage = (((double) (mem.used - mem.buffer - mem.cached)) / mem.total) * 100;

            /* Swap */
            GTop.Swap swap;
            GTop.get_swap (out swap);
            swap_usage = (double) swap.used / swap.total;

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

            var uid = Posix.getuid();
            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode, uid);

            for(int i = 0; i < proclist.number; i++)
            {
                GTop.ProcState proc_state;
                GTop.ProcTime proc_time;
                GTop.ProcArgs proc_args;
                GTop.get_proc_state (out proc_state, pids[i]);
                GTop.get_proc_time (out proc_time, pids[i]);
                var arguments = GTop.get_proc_argv (out proc_args, pids[i]);
                var proc_cmd_full = get_full_process_cmd ((string) proc_state.cmd, arguments);

                if (!(pids[i] in process_table_pid))
                {
                    var process = new Process();
                    process.pid = pids[i];
                    process.alive = true;
                    process.cmdline = get_full_process_cmd ((string) proc_state.cmd, arguments);
                    process.last_processor = proc_state.last_processor;
                    process.cpu_load = 0;
                    process.x_cpu_load = 0;
                    process.cpu_last_used = proc_time.rtime;
                    process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);
                    process.mem_usage = 0;
                    process_table_pid.insert (pids[i], (owned) process);
                }
                else
                {
                    unowned Process process = process_table_pid[pids[i]];
                    process.last_processor = proc_state.last_processor;
                    process.cpu_load = (((double) (proc_time.rtime - process.cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100 *4; //TODO remove * 4 only me for test
                    process.x_cpu_load = (((double) ((proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]) - process.x_cpu_last_used)) / (cpu_data.xcpu_total[process.last_processor] - x_cpu_last_total[process.last_processor])) * 100;
                    //FIX ME: It is always 0, libGTop bug propably
                    //GLib.stdout.printf("X_cpu: " + process.last_processor.to_string() + " " + (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]).to_string() + "\n");
                    process.alive = true;
                    process.cpu_last_used = proc_time.rtime;
                    process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);

                    GTop.ProcMem proc_mem;
                    GTop.get_proc_mem (out proc_mem, process.pid);
                    process.mem_usage = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
                }

                if(proc_cmd_full in process_table_cmdline) //subprocess or update process
                {
                    if(process_table_cmdline[proc_cmd_full].sub_processes != null) //subprocess
                    {
                        if(pids[i] in process_table_cmdline[proc_cmd_full].sub_processes) //update subprocess
                        {
                            unowned Process process = process_table_cmdline[proc_cmd_full].sub_processes[pids[i]];
                            process.last_processor = proc_state.last_processor;
                            process.cpu_load = (((double) (proc_time.rtime - process.cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100 * get_num_processors(); //TODO After fix bug bellow remove: * get_num_processors()
                            process.x_cpu_load = (((double) ((proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]) - process.x_cpu_last_used)) / (cpu_data.xcpu_total[process.last_processor] - x_cpu_last_total[process.last_processor])) * 100;
                            //FIX ME: It is always 0, libGTop bug propably
                            //GLib.stdout.printf("X_cpu: " + process.last_processor.to_string() + " " + (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]).to_string() + "\n");
                            process.alive = true;
                            process.cpu_last_used = proc_time.rtime;
                            process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);

                            GTop.ProcMem proc_mem;
                            GTop.get_proc_mem (out proc_mem, process.pid);
                            process.mem_usage = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
                        }
                        else //add subrow
                        {
                            var process = new Process();
                            process.pid = pids[i];
                            process.alive = true;
                            process.cmdline = proc_cmd_full;
                            process.last_processor = proc_state.last_processor;
                            process.cpu_load = 0;
                            process.x_cpu_load = 0;
                            process.cpu_last_used = proc_time.rtime;
                            process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);
                            process.mem_usage = 0;
                            process_table_cmdline[proc_cmd_full].sub_processes.insert(pids[i], (owned) process);
                        }
                    }
                    else //update process or transform to group and add subrow
                    {
                        if(pids[i] == process_table_cmdline[proc_cmd_full].pid) //update process
                        {
                            unowned Process process = process_table_cmdline[proc_cmd_full];
                            process.last_processor = proc_state.last_processor;
                            process.cpu_load = (((double) (proc_time.rtime - process.cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100 * get_num_processors(); //TODO After fix bug bellow remove: * get_num_processors()
                            process.x_cpu_load = (((double) ((proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]) - process.x_cpu_last_used)) / (cpu_data.xcpu_total[process.last_processor] - x_cpu_last_total[process.last_processor])) * 100;
                            //FIX ME: It is always 0, libGTop bug propably
                            //GLib.stdout.printf("X_cpu: " + process.last_processor.to_string() + " " + (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]).to_string() + "\n");
                            process.alive = true;
                            process.cpu_last_used = proc_time.rtime;
                            process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);

                            GTop.ProcMem proc_mem;
                            GTop.get_proc_mem (out proc_mem, process.pid);
                            process.mem_usage = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
                        }
                        else //add transform to group and add subrow
                        {
                            process_table_cmdline[proc_cmd_full].sub_processes = new HashTable<pid_t?, Process>(int_hash, int_equal);
                            unowned Process process = process_table_cmdline[proc_cmd_full];

                            var sub_process_one = new Process();
                            sub_process_one.pid = process.pid;
                            sub_process_one.alive = process.alive;
                            sub_process_one.cmdline = process.cmdline;
                            sub_process_one.last_processor = process.last_processor;
                            sub_process_one.cpu_load = process.cpu_load;
                            sub_process_one.x_cpu_load = process.x_cpu_load;
                            sub_process_one.cpu_last_used = process.cpu_last_used;
                            sub_process_one.x_cpu_last_used = process.x_cpu_last_used;
                            sub_process_one.mem_usage = process.mem_usage;
                            process_table_cmdline[proc_cmd_full].sub_processes.insert(sub_process_one.pid, (owned) sub_process_one);

                            var sub_process = new Process();
                            sub_process.pid = pids[i];
                            sub_process.alive = true;
                            sub_process.cmdline = proc_cmd_full;
                            sub_process.last_processor = proc_state.last_processor;
                            sub_process.cpu_load = 0;
                            sub_process.x_cpu_load = 0;
                            sub_process.cpu_last_used = proc_time.rtime;
                            sub_process.x_cpu_last_used = (proc_time.xcpu_utime[sub_process.last_processor] + proc_time.xcpu_stime[sub_process.last_processor]);
                            sub_process.mem_usage = 0;
                            process_table_cmdline[proc_cmd_full].sub_processes.insert(pids[i], (owned) sub_process);
                        }
                    }
                }
                else //add process
                {
                     var process = new Process();
                     process.pid = pids[i];
                     process.alive = true;
                     process.cmdline = proc_cmd_full;
                     process.last_processor = proc_state.last_processor;
                     process.cpu_load = 0;
                     process.x_cpu_load = 0;
                     process.cpu_last_used = proc_time.rtime;
                     process.x_cpu_last_used = (proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor]);
                     process.mem_usage = 0;
                     process_table_cmdline.insert(process.cmdline, (owned) process);
                }
            }

            foreach(unowned Process process in process_table_pid.get_values())
            {
                if (process.alive == false)
                    process_table_pid.remove (process.pid);
            }

            foreach(unowned Process process in process_table_cmdline.get_values())
            {
                if(process.sub_processes == null)
                {
                    if(process.alive == false)
                        process_table_cmdline.remove (process.cmdline);
                }
                else
                {
                    int max_value = 0;
                    foreach(unowned Process sub_process in process.sub_processes.get_values())
                    {
                        if (sub_process.alive == false)
                            process.sub_processes.remove(sub_process.pid);

                        if(sub_process.cpu_load > max_value)
                            max_value = (int) sub_process.cpu_load;
                    }
                    process.cpu_load = max_value;

                    if(process.sub_processes.size() == 1) //tranform to process
                    {
                        foreach(unowned Process sub_process in process.sub_processes.get_values()) //only one
                        {
                            process.pid = sub_process.pid;
                            process.alive = sub_process.alive;
                            process.cmdline = sub_process.cmdline;
                            process.last_processor = sub_process.last_processor;
                            process.cpu_load = sub_process.cpu_load;
                            process.x_cpu_load = sub_process.x_cpu_load;
                            process.cpu_last_used = sub_process.cpu_last_used;
                            process.x_cpu_last_used = sub_process.x_cpu_last_used;
                            process.mem_usage = sub_process.mem_usage;
                            process.sub_processes.remove(sub_process.pid);
                            process.sub_processes = null;
                        }
                    }
                    else if(process.sub_processes.size() == 0)
                    {
                        process.sub_processes = null;
                        process.alive = false;
                        process_table_cmdline.remove(process.cmdline);
                    }
                }
            }

            cpu_last_used = used;
            cpu_last_total = cpu_data.total;

            x_cpu_last_used = x_cpu_used;
            x_cpu_last_total = cpu_data.xcpu_total;

            return true;
        }
    }
}
