using Posix;

namespace Usage
{
    [Compact]
    public class Process : Object
    {
        internal pid_t pid;
        internal string cmdline;
        internal string cmdline_parameter; //Isn't parameters as "-p" etc, but parameter for running app, for ex. "--writer' with libreoffice, or "privacy" with gnome-control-center
        internal double cpu_load;
        internal double x_cpu_load;
        internal uint64 cpu_last_used;
        internal uint64 x_cpu_last_used;
        internal uint last_processor;
        internal uint64 mem_usage;
        internal double mem_usage_percentages;
        internal uint64 net_download;
        internal uint64 net_upload;
        internal uint64 net_all;
        internal HashTable<pid_t?, Process> sub_processes;
        internal bool alive;
        internal ProcessStatus status;
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}