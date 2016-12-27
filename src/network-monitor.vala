namespace Usage
{
    public class NetworkMonitor
    {
        public NetworkMonitor()
        {
          /*unowned NetInterface[] net_interfaces_arrary = null;
                    ErrorCode e;

                    // get all network interfaces that netinfo can work with
                    e = NetInterface.list_net_interface(out net_interfaces_arrary);
                    handle_error(e);

                    for(uint32 i = 0; i < net_interfaces_arrary.length; i++)
                    {
                       print_net_interface_info(net_interfaces_arrary[i]); //TODO create array length
                    }

                    // initialize our netinfo object to capture traffic
                    NetInfo netinfo;

                    e = NetInfo.init(net_interfaces_arrary, net_interfaces_arrary.length, out netinfo);
                    handle_error(e);

                    e = NetInterface.free_net_interface_array(net_interfaces_arrary); // this is safe; "netinfo_init()" does not keep references
                    handle_error(e);

                    // start capturing
                    handle_error(netinfo.set_min_refresh_interval(1, 100));
                    handle_error(netinfo.start());*/
        }

        public void update()
        {

        }
    }
}