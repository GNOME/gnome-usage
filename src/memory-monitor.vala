using Posix;

namespace Usage
{
    public class MemoryMonitor
    {
        private double ram_usage;
        private double swap_usage;

        public void update()
        {
            /* Memory */
            GTop.Mem mem;
            GTop.get_mem (out mem);
            ram_usage = (((double) (mem.used - mem.buffer - mem.cached)) / mem.total) * 100;

            /* Swap */
            GTop.Swap swap;
            GTop.get_swap (out swap);
            swap_usage = ((double) swap.used / swap.total) * 100;
        }

        public double get_ram_usage()
        {
            return ram_usage;
        }

        public double get_swap_usage()
        {
            return swap_usage;
        }

        public void get_memory_info_for_pid(pid_t pid, ref uint64 mem_usage, ref double mem_usage_percentages)
        {
            GTop.Mem mem;
            GTop.ProcMem proc_mem;

            GTop.get_mem (out mem);
            GTop.get_proc_mem (out proc_mem, pid);

            mem_usage = (proc_mem.resident - proc_mem.share) / 1000000;
            mem_usage_percentages = ((double) (proc_mem.resident - proc_mem.share) / mem.total) * 100;
        }
    }
}