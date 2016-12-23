using NI;

namespace Usage
{
    /**
        This is only testing interface for NetInfo
    **/
    public class NetMonitor
    {
        private void handle_error(ErrorCode e)
        {
            if(e < 0)
                GLib.stdout.printf("NETINFO ERROR: " + get_error_description(e).to_string() + "\n");
        }

        private void print_net_interface_info(NetInterface i)
        {
            unowned string name;

            ErrorCode e = i.int_get_name(out name);

            if(e < 0)
                GLib.stdout.printf(get_error_description(e).to_string() + "\n");

            GLib.stdout.printf("Network interface: " + name + "\n");
            i.free_string(name);

            Ipv4Addr[] ipv4_addr;
            Ipv6Addr[] ipv6_addr;

            i.int_get_ips(out ipv4_addr, out ipv6_addr);

            for(uint32 j = 0; j < ipv4_addr.length; j++)
            {
                Ipv4Addr ip = ipv4_addr[j];
                GLib.stdout.printf("Ipv4: " + ip.d[0].to_string() + "." + ip.d[1].to_string() + "." + ip.d[2].to_string() + "." + ip.d[3].to_string() + "\n");
            }

            for(uint32 j = 0; j < ipv6_addr.length; j++)
            {
                Ipv6Addr ip = ipv6_addr[j];
                GLib.stdout.printf("Ipv6: %02X%02X", ip.d[0], ip.d[1]);
                for(int k = 1; k < 8; k++)
                    GLib.stdout.printf("::%02X%02X", ip.d[k * 2 + 0], ip.d[k * 2 + 1]);
                GLib.stdout.printf("\n");
            }
            GLib.stdout.printf("\n");
        }

        void handle_thread_errors(NetInfo netinfo)
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

        void get_net_stat(NetInfo netinfo)
        {
            NetStatistics stat;

            handle_error(netinfo.get_net_statistics(out stat));

            unowned NI.Pid[] pids = null;
            handle_error(stat.stat_get_all_pids(out pids));
            for(uint32 i = 0; i < pids.length; i++)
            {
                uint64 bytes = 1;
                handle_error(stat.stat_get_bytes_per_pid(pids[i], out bytes));
                GLib.stdout.printf("Pid " + pids[i].to_string() + ": " + bytes.to_string() + " bytes\n");
            }
            handle_error(NetStatistics.free_pid_array(pids));
        }

        public NetMonitor()
        {
            unowned NetInterface[] net_interfaces_arrary = null;
            ErrorCode e;

            // get all network interfaces that netinfo can work with
            e = NetInterface.list_net_interface(out net_interfaces_arrary);
            handle_error(e);

            for(uint32 i = 0; i < net_interfaces_arrary.length; i++)
            {
               print_net_interface_info(net_interfaces_arrary[i]);
            }

            // initialize our netinfo object to capture traffic
            NetInfo netinfo;

            e = NetInfo.init(net_interfaces_arrary, net_interfaces_arrary.length, out netinfo);
            handle_error(e);

            e = NetInterface.free_net_interface_array(net_interfaces_arrary); // this is safe; "netinfo_init()" does not keep references
            handle_error(e);

            // start capturing
            handle_error(netinfo.set_min_refresh_interval(1, 100));
            handle_error(netinfo.start());

            uint32 second = 0;

            Timeout.add(1000, () => //First load
            {

                handle_thread_errors(netinfo);
                get_net_stat(netinfo);
                handle_error(netinfo.clear());

                GLib.stdout.printf("<------- second " + second.to_string() + " ------>\n");
                second++;
                return true;
            });
        }
    }
}