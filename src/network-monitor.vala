using NI;
using Posix;

namespace Usage
{
    public class NetworkMonitor
    {
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

            upload_usage = bytes_out;
            download_usage = bytes_in;
            net_usage = bytes_all;

            handle_error(netinfo.clear());
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
            uint64 bytes_out = 1;
            Inout inout = InoutEnum.OUTGOING;
            TransportType? transport_type = null;
            NI.Pid pid_ni = (uint64)pid;
            handle_error(stat.get_bytes_per_attr(ref pid_ni, ref inout, ref transport_type, out bytes_out));

            uint64 bytes_in = 1;
            pid_ni = pid;
            inout = InoutEnum.INCOMING;
            transport_type = null;
            handle_error(stat.get_bytes_per_attr(ref pid_ni, ref inout, ref transport_type, out bytes_in));

            uint64 bytes_all = 1;
            pid_ni = pid;
            handle_error(stat.get_bytes_per_pid(pid_ni, out bytes_all));

            upload = bytes_out;
            download = bytes_in;
            all = bytes_all;
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
            uint32 num_errors = 0;
            handle_error(netinfo.pop_thread_errors(out errors));
            if(errors.length > 0)
            {
                handle_error(errors[0]);
            }
            handle_error(netinfo.free_thread_error_array(errors));
        }
    }
}