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
        public double mem_usage { get; private set; }
        public double swap_usage { get; private set; }

        uint64 cpu_last_used = 0;
        uint64 cpu_last_total = 0;

        const int UPDATE_INTERVAL = 1000;
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

		public bool update()
        {
		    /* CPU */
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load = (((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100;

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

            return true;
        }

        public List<unowned Process> get_processes()
        {
            return process_table.get_values();
        }

        public SystemMonitor()
        {
            GTop.init();
            process_table = new HashTable<uint, Process>(direct_hash, direct_equal);
            Timeout.add(UPDATE_INTERVAL, update);
        }
    }
}
