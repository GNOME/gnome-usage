
namespace Usage
{
    public class NetworkMonitor : Monitor
    {
       /* private double bytes_sent;
        private double bytes_recv;
        private PID pid;*/
        private static ListStore network_model;
        private HashTable<int, stats?> network_process_table;
        public NetworkMonitor()
        {
            network_model = new ListStore(typeof(Process));
        }
        public void update()
        {
            SystemMonitor monitor = SystemMonitor.get_default();
            CompareDataFunc<Process> processcmp = (a, b) => {
                Process p_a = (Process) a;
                Process p_b = (Process) b;
                return (int) ((uint64) (p_a.net_stats.bytes_recv < p_b.net_stats.bytes_recv) - (uint64) (p_a.net_stats.bytes_recv > p_b.net_stats.bytes_recv));
                };
            try
           {
                network_process_table = NetworkSubView.netstats_dbus.get_stats();
           }catch(IOError e){
               stderr.printf ("%s\n",e.message);
           }
           if(network_process_table.size() != 0)
                network_model.remove_all();
            network_process_table.foreach ((key, val) => {
                Process proc_global = monitor.get_process_by_pid((Pid)key);
                if(proc_global != null)
                {
                    Process temp = new Process((Pid)key,proc_global.cmdline,proc_global.cmdline_parameter,proc_global.display_name,proc_global.uid);
                    if(temp != null)
                    {
                        temp.net_stats = new NetStats_details(((stats)val).bytes_sent, ((stats)val).bytes_recv);
                        network_model.insert_sorted(temp, processcmp);
                    }
                }
            });
            network_process_table.remove_all();
        }

        public void update_process(ref Process process)
        {

        }

        public  static ListStore get_network_model()
        {
            return network_model;
        }

        public void free_network_table()
        {

        }

    }
}
