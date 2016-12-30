[CCode(cheader_filename = "netinfo.h")]
namespace NI
{
    [CCode(cname = "void", free_function = "netinfo_free")]
    [Compact]
    public class NetInfo
    {
        [CCode(cname = "netinfo_init")]
        public static ErrorCode init(NetInterface* interfaces, uint32 num_net_interfaces, out NetInfo n_out);

        // not influenced by netinfo_clear(). This has to be free with "netinfo_free(statistics);"
        [CCode(cname = "netinfo_get_net_statistics")]
        public ErrorCode get_net_statistics(out NetStatistics ns);

        // Resets the internal statistics. Does not influence already published statistics from netinfo_get_statistics().
        [CCode(cname = "netinfo_clear")]
        public ErrorCode clear();

        // This function will start the packet capture by creating a new capture thread for each network interface.
        [CCode(cname = "netinfo_start")]
        public ErrorCode start();

        // Stop the worker thread started with `netinfo_start()`. Might not happen immediatly. Please see `https://docs.rs/netinfo` for more information/conditions.
        [CCode(cname = "netinfo_stop")]
        public ErrorCode stop();

        // Please see `https://docs.rs/netinfo` for more information.
        [CCode(cname = "netinfo_set_min_refresh_interval")]
        public ErrorCode set_min_refresh_interval(Boolean activate_min_refresh_interval, uint32 milliseconds);

        // Retrieve error in worker thread started with `netinfo_start_async()`. Please see `https://docs.rs/netinfo` for more information.
        [CCode(cname = "netinfo_pop_thread_errors")]
        public ErrorCode pop_thread_errors(out unowned ErrorCode[] worker_thread_errors_out);

        [CCode(cname = "netinfo_free_thread_error_array")]
        public static ErrorCode free_thread_error_array(ErrorCode[] worker_thread_error_array);
    }

    [SimpleType]
    [CCode (cname="ni_net_interface")]
    public struct NetInterface
    {
        [CCode(cname = "netinfo_list_net_interface")]
        public static ErrorCode list_net_interface(out unowned NetInterface[] net_interfaces_array_out);

        [CCode(cname = "netinfo_int_get_name")]
        private ErrorCode _int_get_name (out unowned uint8[] name_out);

        public ErrorCode int_get_name (out unowned string name)
        {
            unowned uint8[] name_u;
            var return_val = _int_get_name (out name_u);
            name = (string?) name_u;
            return return_val;
        }

        [CCode(cname = "netinfo_free_string")]
        private static ErrorCode _free_string (uint8[] s);

        public ErrorCode free_string (string name)
        {
            unowned uint8[] name_u = (uint8[]) name;
            return _free_string (name_u);
        }

        [CCode(cname = "netinfo_int_get_index")]
        public ErrorCode int_get_index(out uint32 index_out);

        [CCode(cname = "netinfo_int_get_mac")]
        public ErrorCode int_get_mac(out Boolean has_mac_out, out MacAddr mac_out);

        [CCode(cname = "netinfo_int_get_ips", free_function = "netinfo_free_ip_arrays")]
        public ErrorCode int_get_ips(out Ipv4Addr[] ip4_array_out, out Ipv6Addr[] ip6_array_out);

        [CCode(cname = "netinfo_int_get_flags")]
        public ErrorCode int_get_flags(out uint32 flags_out);

        // All types use the opaque pointer idiom, so "ni_net_interface" is a pointer. Calling this
        // free function will invalidate all pointers (all "ni_net_interface" objects). So
        // make sure to call "netinfo_init()" with your network interfaces beforehand.
        [CCode(cname = "netinfo_free_net_interface_array")]
        public static ErrorCode free_net_interface_array(NetInterface[] net_interfaces_array);
    }

    [CCode(cname = "void", free_function = "netinfo_free_stat")]
    [Compact]
    public class NetStatistics
    {
        [CCode(cname = "netinfo_stat_get_total_bytes")]
        public ErrorCode get_total_bytes(out uint64 bytes_out);
        [CCode(cname = "netinfo_stat_get_bytes_per_pid")]
        public ErrorCode get_bytes_per_pid(Pid pid, out uint64 bytes_out);
        [CCode(cname = "netinfo_stat_get_unassigned_bytes")]
        public ErrorCode get_unassigned_bytes(out uint64 bytes_out);
        [CCode(cname = "netinfo_stat_get_bytes_by_transport_type")]
        public ErrorCode get_bytes_by_transport_type(TransportType t, out uint64 bytes_out);
        [CCode(cname = "netinfo_stat_get_bytes_by_inout_type")]
        public ErrorCode get_bytes_by_inout_type(Inout t, out uint64 bytes_out);

        // Returns all pids that had some traffic since the last "netinfo_clear()"
        [CCode(cname = "netinfo_stat_get_all_pids")]
        public ErrorCode get_all_pids(out unowned Pid[] pid_array_out);
        [CCode(cname = "netinfo_free_pid_array")]
        public static ErrorCode free_pid_array(Pid[] pid_array);

        // This function will return the number of bytes used by (pid, inout_type, transport_type). For example
        // that way you can get the "outgoing udp bytes for pid 1234".
        //
        // Prividing NULL for...
        //   ...pid_opt means all bytes/traffic that could not be assigned to a pid
        //   ...inout_opt and tt_opt means the value can be arbitrary.
        //
        // Example: (1234, NULL, tcp) will return the number of bytes of the tcp traffic (incoming and outgoing) for pid 1234.
        // Example: (1234, incoming, NULL) will return the number of bytes of the incoming traffic (tcp and udp) for pid 1234.
        [CCode(cname = "netinfo_stat_get_bytes_per_attr")]
        public ErrorCode get_bytes_per_attr(ref Pid pid_opt, ref Inout inout_opt, ref TransportType tt_opt, out uint64 bytes_out);
    }

    [SimpleType]
    [CCode(cname = "ni_error_code", has_type_id = false)]
    public struct ErrorCode : int32 {}

    [SimpleType]
    [CCode(cname = "ni_boolean", has_type_id = false)]
    public struct Boolean : int8 {}

    [SimpleType]
    [CCode(cname = "ni_pid", has_type_id = false)]
    public struct Pid : uint64 {}

    [CCode(cname = "ni_mac_addr", has_type_id = false)]
    public struct MacAddr {
        uint8 d[6];
    }

    [CCode(cname = "ni_ipv4_addr", has_type_id = false)]
    public struct Ipv4Addr {
        uint8 d[4];
    }

    [CCode(cname = "ni_ipv6_addr", has_type_id = false)]
    public struct Ipv6Addr {
        uint8 d[16];
    }

    [CCode(cname = "ni_inout_enum", cprefix = "NETINFO_IOT_", has_type_id = false)]
    public enum InoutEnum {
        INCOMING,
        OUTGOING
    }

    [SimpleType]
    [CCode(cname = "ni_inout", has_type_id = false)]
    public struct Inout : uint32 {}

    [CCode(cname = "ni_transport_type_enum", cprefix = "NETINFO_TT_", has_type_id = false)]
    public enum TransportTypeEnum {
        TCP,
        UDP
    }

    [SimpleType]
    [CCode(cname = "ni_transport_type", has_type_id = false)]
    public struct TransportType : uint32 {}

    // this function returns NULL on error (but that should not happen too often...)
    [CCode(cname = "netinfo_get_error_description")]
    public uint8 get_error_description(ErrorCode error_code);
}
