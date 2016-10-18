using Posix;

namespace Usage
{
    [Compact]
    public class Process
    {
        internal uint pid;
        internal string cmdline;
        internal double cpu_load;
        internal uint64 cpu_last_used;
        internal double mem_usage;

        internal bool alive;
    }

    public class SystemMonitor
    {
        public double cpu_load { get; private set; }
        public double cpu_load_graph { get; private set; }
        public double[] x_cpu_load { get; private set; }
        public double[] x_cpu_load_graph { get; private set; }
        public double mem_usage { get; private set; }
        public double mem_usage_graph { get; private set; }
        public double swap_usage { get; private set; }
        public double swap_usage_graph { get; private set; }

        uint update_graph_interval = 0;
        uint update_interval = 0;

        uint64 cpu_last_used = 0;
        uint64 cpu_last_used_graph = 0;
        uint64 cpu_last_total = 0;
        uint64 cpu_last_total_graph = 0;

        uint64[] x_cpu_last_used;
        uint64[] x_cpu_last_used_graph;
        uint64[] x_cpu_last_total;
        uint64[] x_cpu_last_total_graph;

        bool change_graph_timeout = false;
        bool change_timeout = false;

        HashTable<uint, Process> process_table;

		private int process_mode = GTop.KERN_PROC_ALL;

		public enum ProcessMode
        {
		    ALL,
  			USER,
  			EXCLUDE_IDLE
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

            foreach (unowned Process process in process_table.get_values())
            	process.alive = false;

            var uid = Posix.getuid();
            GTop.Proclist proclist;
            var pids = GTop.get_proclist (out proclist, process_mode, uid);

            for(int i = 0; i < proclist.number; i++)
            {
                GTop.ProcState proc_state;
                GTop.ProcTime proc_time;
                GTop.get_proc_state (out proc_state, pids[i]);
                GTop.get_proc_time (out proc_time, pids[i]);

                if (!(pids[i] in process_table))
                {
                    var process = new Process();
                    process.pid = pids[i];
                    process.alive = true;
                    process.cmdline = (string) proc_state.cmd;
                    process.cpu_load = 0;
                    process.cpu_last_used = proc_time.rtime;
                    process.mem_usage = 0;
                    process_table.insert (pids[i], (owned) process);
                }
                else
                {
                    unowned Process process = process_table[pids[i]];
                    process.cpu_load = (((double) (proc_time.rtime - process.cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100;
                    process.alive = true;
                    process.cpu_last_used = proc_time.rtime;

                    GTop.ProcMem proc_mem;
                    GTop.get_proc_mem (out proc_mem, process.pid);
                    process.mem_usage = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
                }
            }

            foreach(unowned Process process in process_table.get_values())
            {
                if (process.alive == false)
                    process_table.remove (process.pid);
            }

            cpu_last_used = used;
            cpu_last_total = cpu_data.total;

            x_cpu_last_used = x_cpu_used;
            x_cpu_last_total = cpu_data.xcpu_total;

            if(change_graph_timeout)
            {
                Timeout.add(update_interval, update_data);
                return false;
            }

            return true;
        }

        private bool update_graph_data()
        {
            /* CPU */
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load_graph = (((double) (used - cpu_last_used_graph)) / (cpu_data.total - cpu_last_total_graph)) * 100;

            var x_cpu_used = new uint64[get_num_processors()];
            for (int i = 0; i < x_cpu_load_graph.length; i++)
            {
                x_cpu_used[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
                x_cpu_load_graph[i] = (((double) (x_cpu_used[i] - x_cpu_last_used_graph[i])) / (cpu_data.xcpu_total[i] - x_cpu_last_total_graph[i])) * 100;
            }

            /* Memory */
            GTop.Mem mem;
            GTop.get_mem (out mem);
            mem_usage_graph = (((double) (mem.used - mem.buffer - mem.cached)) / mem.total) * 100;

            /* Swap */
            GTop.Swap swap;
            GTop.get_swap (out swap);
            swap_usage_graph = (double) swap.used / swap.total;

            cpu_last_used_graph = used;
            cpu_last_total_graph = cpu_data.total;

            x_cpu_last_used_graph = x_cpu_used;
            x_cpu_last_total_graph = cpu_data.xcpu_total;


            if(change_graph_timeout)
            {
                Timeout.add(update_graph_interval, update_graph_data);
                return false;
            }

            return true;
        }

        public void set_update_graph_interval(uint miliseconds)
        {
            change_graph_timeout = true;
            update_graph_interval = miliseconds;
        }

        public uint get_update_graph_interval()
        {
            return update_graph_interval;
        }

        public void set_update_interval(uint miliseconds)
        {
            change_timeout = true;
            update_interval = miliseconds;
        }

        public uint get_update_interval()
        {
            return update_interval;
        }

        public List<unowned Process> get_processes()
        {
            return process_table.get_values();
        }

        public SystemMonitor(int update_interval)
        {
            GTop.init();

            x_cpu_load = new double[get_num_processors()];
            x_cpu_load_graph = new double[get_num_processors()];
            x_cpu_last_used = new uint64[get_num_processors()];
            x_cpu_last_used_graph = new uint64[get_num_processors()];
            x_cpu_last_total = new uint64[get_num_processors()];
            x_cpu_last_total_graph = new uint64[get_num_processors()];
            process_table = new HashTable<uint, Process>(direct_hash, direct_equal);
            this.update_interval = update_interval;
            Timeout.add(update_interval, update_data);
            Timeout.add(100, update_graph_data);
        }
    }
}
