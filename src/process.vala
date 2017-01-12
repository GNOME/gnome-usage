using Posix;

namespace Usage
{
    [Compact]
    public class Process : Object
    {
        pid_t pid;
        string cmdline;
        string cmdline_parameter; //Isn't parameters as "-p" etc, but parameter for running app, for ex. "--writer' with libreoffice, or "privacy" with gnome-control-center
        double cpu_load;
        double x_cpu_load;
        uint64 cpu_last_used;
        uint64 x_cpu_last_used;
        uint last_processor;
        uint64 mem_usage;
        double mem_usage_percentages;
        uint64 net_download;
        uint64 net_upload;
        uint64 net_all;
        HashTable<pid_t?, Process>? sub_processes;
        bool alive;
        ProcessStatus status;

        public Process(pid_t pid, string cmdline, string cmdline_parameter)
        {
            this.pid = pid;
            this.cmdline = cmdline;
            this.cmdline_parameter = cmdline_parameter;
            this.cpu_load = 0;
            this.x_cpu_load = 0;
            this.cpu_last_used = 0;
            this.x_cpu_last_used = 0;
            this.last_processor = 0;
            this.mem_usage = 0;
            this.mem_usage_percentages = 0;
            this.net_download = 0;
            this.net_upload = 0;
            this.net_all = 0;
            this.sub_processes = null;
            this.alive = true;
            this.status = ProcessStatus.SLEEPING;
        }

        public void update_from_process(Process process)
        {
            this.last_processor = process.get_last_processor();
            this.cpu_load = process.get_cpu_load();
            this.x_cpu_load = process.get_x_cpu_load();
            this.cpu_last_used = process.get_cpu_last_used();
            this.x_cpu_last_used = process.get_x_cpu_last_used();
            this.mem_usage = process.get_mem_usage();
            this.net_download = process.get_net_download();
            this.net_upload = process.get_net_upload();
            this.net_all = process.get_net_all();
            this.alive = process.get_alive();
            this.status = process.get_status();
        }

        public pid_t get_pid()
        {
            return pid;
        }

        public void set_pid(pid_t pid)
        {
            this.pid = pid;
        }

        public string get_cmdline()
        {
            return cmdline;
        }

        public void set_cmdline(string cmdline)
        {
            this.cmdline = cmdline;
        }

        public string get_cmdline_parameter()
        {
            return cmdline_parameter;
        }

        public void set_cmdline_parameter(string cmdline_parameter)
        {
            this.cmdline_parameter = cmdline_parameter;
        }

        public double get_cpu_load()
        {
            return cpu_load;
        }

        public void set_cpu_load(double cpu_load)
        {
            this.cpu_load = cpu_load;
        }

        public double get_x_cpu_load()
        {
            return x_cpu_load;
        }

        public void set_x_cpu_load(double x_cpu_load)
        {
            this.x_cpu_load = x_cpu_load;
        }

        public uint64 get_cpu_last_used()
        {
            return cpu_last_used;
        }

        public void set_cpu_last_used(uint64 cpu_last_used)
        {
            this.cpu_last_used = cpu_last_used;
        }

        public uint64 get_x_cpu_last_used()
        {
            return x_cpu_last_used;
        }

        public void set_x_cpu_last_used(uint64 x_cpu_last_used)
        {
            this.x_cpu_last_used = x_cpu_last_used;
        }

        public uint get_last_processor()
        {
            return last_processor;
        }

        public void set_last_processor(uint last_processor)
        {
            this.last_processor = last_processor;
        }

        public uint64 get_mem_usage()
        {
            return mem_usage;
        }

        public void set_mem_usage(uint64 mem_usage)
        {
            this.mem_usage = mem_usage;
        }

        public double get_mem_usage_percentages()
        {
            return mem_usage_percentages;
        }

        public void set_mem_usage_percentages(double mem_usage_percentages)
        {
            this.mem_usage_percentages = mem_usage_percentages;
        }

        public uint64 get_net_download()
        {
            return net_download;
        }

        public void set_net_download(uint64 net_download)
        {
            this.net_download = net_download;
        }

        public uint64 get_net_upload()
        {
            return net_upload;
        }

        public void set_net_upload(uint64 net_upload)
        {
            this.net_upload = net_upload;
        }

        public uint64 get_net_all()
        {
            return net_all;
        }

        public void set_net_all(uint64 net_all)
        {
            this.net_all = net_all;
        }

        public HashTable<pid_t?, Process>? get_sub_processes()
        {
            return sub_processes;
        }

        public void set_sub_processes(HashTable<pid_t?, Process>? sub_processes)
        {
            this.sub_processes = sub_processes;
        }

        public bool get_alive()
        {
            return alive;
        }

        public void set_alive(bool alive)
        {
            this.alive = alive;
        }

        public ProcessStatus get_status()
        {
            return status;
        }

        public void set_status(ProcessStatus status)
        {
            this.status = status;
        }
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}