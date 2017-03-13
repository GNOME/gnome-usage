namespace Usage
{
    public class MemoryMonitor
    {
        private uint64 ram_usage;
        private uint64 ram_total;
        private uint64 swap_usage;
        private uint64 swap_total;

        public void update()
        {
            /* Memory */
            GTop.Mem mem;
            GTop.get_mem (out mem);
            ram_usage = mem.used - mem.buffer - mem.cached;
            ram_total = mem.total;

            /* Swap */
            GTop.Swap swap;
            GTop.get_swap (out swap);
            swap_usage = swap.used;
            swap_total = swap.total;
        }

        public uint64 get_ram_usage()
        {
            return ram_usage;
        }
        public uint64 get_swap_usage()
        {
            return swap_usage;
        }
        public uint64 get_ram_total()
        {
            return ram_total;
        }
        public uint64 get_swap_total()
        {
            return swap_total;
        }

        public void update_process_info(ref Process process)
        {
            GTop.Mem mem;
            GTop.ProcMem proc_mem;

            GTop.get_mem (out mem);
            GTop.get_proc_mem (out proc_mem, process.get_pid());

            process.set_mem_usage(proc_mem.resident - proc_mem.share);
        }
    }
}