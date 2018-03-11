
namespace Usage
{
    public class NetworkMonitor : Monitor
    {
       /* private double bytes_sent;
        private double bytes_recv;
        private PID pid;*/
        private HashTable<int, stats?> network_process_table;
        public void update()
        {   
            network_process_table = new HashTable<int, stats?>(int_hash, int_equal);
            try
            {
               network_process_table = NetworkSubView.netstats_dbus.get_stats();

            }catch(IOError e) {
                stderr.printf ("%s\n", e.message);
            }    
            //Note :free this Hashtable after processes have been created
        }

        public void update_process(ref Process process)
        {

        }

        public HashTable<int, stats?> get_network_table()
        {
            return network_process_table;
        }

        public void free_network_table()
        {
            network_process_table.remove_all();
        }
    }
}
