namespace Usage
{
    public class CpuMonitor
    {
        private double cpu_load;
        private double[] x_cpu_load;
        private uint64 cpu_last_used = 0;
        private uint64 cpu_last_total = 0;
        private uint64 cpu_last_total_step = 0;
        private uint64[] x_cpu_last_used;
        private uint64[] x_cpu_last_total;

        public CpuMonitor()
        {
            x_cpu_load = new double[get_num_processors()];
            x_cpu_last_used = new uint64[get_num_processors()];
            x_cpu_last_total = new uint64[get_num_processors()];
        }

        public void update()
        {
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load = (((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total)) * 100;
            cpu_last_total_step = cpu_data.total - cpu_last_total;

            var x_cpu_used = new uint64[get_num_processors()];
            for (int i = 0; i < x_cpu_load.length; i++)
            {
                x_cpu_used[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
                x_cpu_load[i] = (((double) (x_cpu_used[i] - x_cpu_last_used[i])) / (cpu_data.xcpu_total[i] - x_cpu_last_total[i])) * 100;
            }

            cpu_last_used = used;
            cpu_last_total = cpu_data.total;
            x_cpu_last_used = x_cpu_used;
            x_cpu_last_total = cpu_data.xcpu_total;
        }

        public double get_cpu_load()
        {
            return cpu_load;
        }

        public double[] get_x_cpu_load()
        {
            return x_cpu_load;
        }

        public void update_process_info(ref Process process)
        {
            GTop.ProcTime proc_time;
            GTop.ProcState proc_state;

            GTop.get_proc_time (out proc_time, process.get_pid());
            GTop.get_proc_state (out proc_state, process.get_pid());

            process.set_last_processor(proc_state.last_processor);
            double cpu_load = (((double) (proc_time.rtime - process.get_cpu_last_used())) / cpu_last_total_step) * 100 * get_num_processors();
            cpu_load = double.min(100, cpu_load);
            process.set_cpu_load(cpu_load);
            process.set_cpu_last_used(proc_time.rtime);
            process.set_x_cpu_last_used(proc_time.xcpu_utime[process.get_last_processor()] + proc_time.xcpu_stime[process.get_last_processor()]);
        }
    }
}