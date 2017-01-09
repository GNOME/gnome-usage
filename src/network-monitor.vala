using NI;
using Posix;

namespace Usage
{
    public class NetworkMonitor
    {
        private uint64 download_usage_actual;
        private uint64 upload_usage_actual;
        private uint64 net_usage_actual;
        private uint64 download_usage;
        private uint64 upload_usage;
        private uint64 net_usage;
        private NetInfo netinfo;
        private NetStatistics stat;

        public NetworkMonitor()
        {
            unowned NetInterface[] net_interfaces_arrary = null;

            handle_error(NetInterface.list_net_interface(out net_interfaces_arrary));

            handle_error(NetInfo.init(net_interfaces_arrary, net_interfaces_arrary.length, out netinfo));
            handle_error(NetInterface.free_net_interface_array(net_interfaces_arrary));

            handle_error(netinfo.set_min_refresh_interval(1, 1000));
            handle_error(netinfo.start());
        }

        ~NetworkMonitor ()
        {
            handle_error(netinfo.clear());
        }

        public void update()
        {
            handle_thread_errors();
            handle_error(netinfo.get_net_statistics(out stat));

            uint64 bytes_out;
            uint64 bytes_in;
            uint64 bytes_all;
            handle_error(stat.get_bytes_by_inout_type(InoutEnum.OUTGOING, out bytes_out));
            handle_error(stat.get_bytes_by_inout_type(InoutEnum.INCOMING, out bytes_in));
            handle_error(stat.get_total_bytes(out bytes_all));

            uint64 bytes_all_unasigned;
            uint64 bytes_in_unasigned;
            uint64 bytes_out_unasigned;
            handle_error(stat.get_bytes_per_attr(null, InoutEnum.OUTGOING, null, out bytes_out_unasigned));
            handle_error(stat.get_bytes_per_attr(null, InoutEnum.INCOMING, null, out bytes_in_unasigned));
            handle_error(stat.get_unassigned_bytes(out bytes_all_unasigned));

            upload_usage_actual = bytes_out;
            download_usage_actual = bytes_in;
            net_usage_actual = bytes_all;

            upload_usage += bytes_out - bytes_out_unasigned;
            download_usage += bytes_in - bytes_in_unasigned;
            net_usage += bytes_all - bytes_all_unasigned;// TODO clear it every 5sec or? Mabe 30 sec will beter

            handle_error(netinfo.clear());
        }

        public uint64 get_net_download_actual()
        {
            return download_usage_actual;
        }

        public uint64 get_net_upload_actual()
        {
            return upload_usage_actual;
        }

        public uint64 get_net_usage_actual()
        {
            return net_usage_actual;
        }

        public uint64 get_net_download()
        {
            return download_usage;
        }

        public uint64 get_net_upload()
        {
            return upload_usage;
        }

        public uint64 get_net_usage()
        {
            return net_usage;
        }

        public void get_network_info_for_pid(pid_t pid, ref uint64 download, ref uint64 upload, ref uint64 all)
        {
            uint64 bytes_out;
            uint64 bytes_in;
            uint64 bytes_all;
            handle_error(stat.get_bytes_per_attr(pid, InoutEnum.OUTGOING, null, out bytes_out));
            handle_error(stat.get_bytes_per_attr(pid, InoutEnum.INCOMING, null, out bytes_in));
            handle_error(stat.get_bytes_per_pid(pid, out bytes_all));

            upload += bytes_out;
            download += bytes_in;
            all += bytes_all;
        }

        private void handle_error(ErrorCode e)
        {
            if(e < 0)
            {
                GLib.stdout.printf("NETINFO ERROR: " + get_error_description(e).to_string() + "\n");
                GLib.stdout.printf("Do you have sudo, or setcap for binary?\n");
            }
        }

        void handle_thread_errors()
        {
            unowned ErrorCode[] errors = null;
            handle_error(netinfo.pop_thread_errors(out errors));
            if(errors.length > 0)
            {
                handle_error(errors[0]);
            }
            handle_error(NetInfo.free_thread_error_array(errors));
        }
    }
}