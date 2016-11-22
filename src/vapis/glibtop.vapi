[CCode(cheader_filename = "glibtop.h", lower_case_cprefix = "glibtop_")]
namespace GTop {

    public void init();

    [CCode(cname = "glibtop_cpu", cheader_filename = "glibtop/cpu.h")]
    public struct Cpu {
        uint64 flags;
        uint64 total;
        uint64 user;
        uint64 nice;
        uint64 sys;
        uint64 idle;
        uint64 iowait;
        uint64 irq;
        uint64 softirq;
        uint64 frequency;
        uint64 xcpu_total[32];
        uint64 xcpu_user[32];
        uint64 xcpu_nice[32];
        uint64 xcpu_sys[32];
        uint64 xcpu_idle[32];
        uint64 xcpu_iowait[32];
        uint64 xcpu_irq[32];
        uint64 xcpu_softirq[32];
        uint64 xcpu_flags;
    }
    public void get_cpu(out Cpu cpu);

    [CCode(cname = "GLIBTOP_KERN_PROC_ALL")]
    public const int KERN_PROC_ALL;
    [CCode(cname = "GLIBTOP_KERN_PROC_UID")]
    public const int KERN_PROC_UID;
    [CCode(cname = "GLIBTOP_EXCLUDE_IDLE")]
    public const int EXCLUDE_IDLE;

    [CCode(cname = "glibtop_proclist", cheader_filename = "glibtop/proclist.h")]
    public struct Proclist {
        uint64 flags;
        uint64 number;
        uint64 total;
        uint64 size;
    }
    [CCode(array_length = false, array_null_terminated = false)]
    public Posix.pid_t[] get_proclist(out Proclist proclist, uint64 which, uint64 arg);

    [CCode(cname = "glibtop_proc_state", cheader_filename = "glibtop/procstate.h")]
    public struct ProcState {
        uint64 flags;
        char cmd[40];
        uint state;
        int uid;
        int gid;
        int ruid;
        int rgid;
        int has_cpu;
        int processor;
        int last_processor;
    }
    public void get_proc_state(out ProcState proc_state, Posix.pid_t pid);

    [CCode(cname = "glibtop_proc_time", cheader_filename = "glibtop/proctime.h")]
    public struct ProcTime {
        uint64 flags;
        uint64 start_time;
        uint64 rtime;
        uint64 utime;
        uint64 stime;
        uint64 cutime;
        uint64 cstime;
        uint64 timeout;
        uint64 it_real_value;
        uint64 frequency;
        uint64 xcpu_utime[32];
        uint64 xcpu_stime[32];
    }
    public void get_proc_time(out ProcTime proc_time, Posix.pid_t pid);

    [CCode(cname = "glibtop_mem", cheader_filename = "glibtop/mem.h")]
    public struct Mem {
        uint64 flags;
        uint64 total;
        uint64 used;
        uint64 free;
        uint64 shared;
        uint64 buffer;
        uint64 cached;
        uint64 user;
        uint64 locked;
    }
    public void get_mem(out Mem mem);

    [CCode(cname = "glibtop_swap", cheader_filename = "glibtop/swap.h")]
    public struct Swap {
        uint64 flags;
        uint64 total;
        uint64 used;
        uint64 free;
        uint64 pagein;
        uint64 pageout;
    }
    public void get_swap(out Swap swap);

    [CCode(cname = "glibtop_proc_mem", cheader_filename = "glibtop/procmem.h")]
    public struct ProcMem {
        uint64 flags;
        uint64 size;
        uint64 vsize;
        uint64 resident;
        uint64 share;
        uint64 rss;
        uint64 rss_rlim;
    }
    public void get_proc_mem(out ProcMem proc_mem, Posix.pid_t pid);

    [CCode(cname = "glibtop_netlist", cheader_filename = "glibtop/netlist.h")]
    public struct Netlist {
        uint64 flags;
        uint32 number;
    }

    [CCode(array_length = false, array_null_terminated = false)]
    public string[] get_netlist(out Netlist netlist);

    [CCode(cname = "glibtop_proc_uid", cheader_filename = "glibtop/procuid.h")]
    public struct ProcUid {
        uint64 flags;
        int32 uid;
        int32 euid;
        int32 gid;
        int32 egid;
        int32 suid;
        int32 sgid;
        int32 fsuid;
        int32 fsgid;
        int32 pid;
        int32 ppid;
        int32 pgrp;
        int32 session;
        int32 tty;
        int32 tpgid;
        int32 priority;
        int32 nice;
        int32 ngroups;
        int32 groups[64];
    }
    public void get_proc_uid(out ProcUid proc_uid, Posix.pid_t pid);

    [CCode(cname = "glibtop_proc_args", cheader_filename = "glibtop/procargs.h")]
    public struct ProcArgs {
        uint64 flags;
        uint64 size;
    }
    public string[] get_proc_argv(out ProcArgs proc_args, Posix.pid_t pid);
}
