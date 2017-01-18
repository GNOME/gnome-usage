#ifndef _NETINFO_HEADER_DEF_
#define _NETINFO_HEADER_DEF_

/**
 * For documentation of the Rust library see: https://docs.rs/netinfo/0.2.0/netinfo/.
 * This FFI is a straightforward implemention of the Rust library, so the API is _very_
 * similar.
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif


typedef void* ni_netinfo;
typedef void* ni_net_interface;
typedef void* ni_net_statistics;
typedef int32_t ni_error_code;

typedef uint8_t ni_boolean;

typedef uint64_t ni_pid;

typedef struct {
  uint8_t d[6];
} ni_mac_addr;

typedef struct {
  uint8_t d[4];
} ni_ipv4_addr;

typedef struct {
  uint8_t d[16];
} ni_ipv6_addr;

typedef enum {
  NETINFO_IOT_INCOMING = 0,
  NETINFO_IOT_OUTGOING = 1,
} ni_inout_enum;
typedef uint32_t ni_inout;

typedef enum {
  NETINFO_TT_TCP = 0,
  NETINFO_TT_UDP = 1,
} ni_transport_type_enum;
typedef uint32_t ni_transport_type;


////////////////////////////////////////////////////////////////////////////////
// Network-Interface related functions
////////////////////////////////////////////////////////////////////////////////

ni_error_code netinfo_list_net_interface(ni_net_interface** net_interfaces_array_out, uint32_t* num_net_interfaces_out);
ni_error_code netinfo_int_get_name(ni_net_interface i, uint8_t** name_out, uint32_t* name_len_out);
ni_error_code netinfo_free_string(uint8_t* s, uint32_t len);
ni_error_code netinfo_int_get_index(ni_net_interface i, uint32_t* index_out);

// TODO: due to a type reexporting issue in netinfo 0.2 this will return the mac_addr zero
ni_error_code netinfo_int_get_mac(ni_net_interface i, ni_boolean* has_mac_out, ni_mac_addr* mac_out);
ni_error_code netinfo_int_get_ips(ni_net_interface i, ni_ipv4_addr** ip4_array_out, uint32_t* num_ip4_out, ni_ipv6_addr** ip6_array_out, uint32_t* num_ip6_out);
ni_error_code netinfo_free_ip_arrays(ni_ipv4_addr* ip4_array, uint32_t len_ipv4, ni_ipv6_addr* ip6_array, uint32_t len_ipv6);
ni_error_code netinfo_int_get_flags(ni_net_interface i, uint32_t* flags_out);


// All types use the opaque pointer idiom, so "ni_net_interface" is a pointer. Calling this
// free function will invalidate all pointers (all "ni_net_interface" objects). So
// make sure to call "netinfo_init()" with your network interfaces beforehand.
ni_error_code netinfo_free_net_interface_array(ni_net_interface* net_interfaces_array, uint32_t len);

////////////////////////////////////////////////////////////////////////////////
// "ni_netinfo" functions
////////////////////////////////////////////////////////////////////////////////

// WARNING: netinfo 0.2.0 only supports handling one network interface. When providing multiple interfaces, only the first interface
// will be used.
ni_error_code netinfo_init(ni_net_interface* interfaces, uint32_t num_net_interfaces, ni_netinfo* n_out);

// not influenced by netinfo_clear(). This has to be free with "netinfo_free(statistics);"
ni_error_code netinfo_get_net_statistics(ni_netinfo n, ni_net_statistics* ns);

// Resets the internal statistics. Does not influence already published statistics from netinfo_get_statistics().
ni_error_code netinfo_clear(ni_netinfo n);

// This function will start the packet capture by creating a new capture thread for each network interface.
ni_error_code netinfo_start(ni_netinfo n);

// Stop the worker thread started with `netinfo_start()`. Might not happen immediatly. Please see `https://docs.rs/netinfo` for more information/conditions.
ni_error_code netinfo_stop(ni_netinfo n);

// Please see `https://docs.rs/netinfo` for more information.
ni_error_code netinfo_set_min_refresh_interval(ni_netinfo n, ni_boolean activate_min_refresh_interval, uint32_t milliseconds);

// Retrieve error in worker thread started with `netinfo_start_async()`. Please see `https://docs.rs/netinfo` for more information.
ni_error_code netinfo_pop_thread_errors(ni_netinfo n, ni_error_code** worker_thread_errors_out, uint32_t* num_errors_out);
ni_error_code netinfo_free_thread_error_array(ni_error_code* worker_thread_error_array, uint32_t len);

// This function will free all internally used memory.
ni_error_code netinfo_free(ni_netinfo n);



////////////////////////////////////////////////////////////////////////////////
// "ni_net_statistics" functions
////////////////////////////////////////////////////////////////////////////////

ni_error_code netinfo_stat_get_total_bytes(ni_net_statistics s, uint64_t* bytes_out);
ni_error_code netinfo_stat_get_bytes_per_pid(ni_net_statistics s, ni_pid pid, uint64_t* bytes_out);
ni_error_code netinfo_stat_get_unassigned_bytes(ni_net_statistics s, uint64_t* bytes_out);
ni_error_code netinfo_stat_get_bytes_by_transport_type(ni_net_statistics s, ni_transport_type t, uint64_t* bytes_out);
ni_error_code netinfo_stat_get_bytes_by_inout_type(ni_net_statistics s, ni_inout t, uint64_t* bytes_out);

// Returns all pids that had some traffic since the last "netinfo_clear()"
ni_error_code netinfo_stat_get_all_pids(ni_net_statistics s, ni_pid** pid_array_out, uint32_t* num_pids_out);
ni_error_code netinfo_free_pid_array(ni_pid* pid_array, uint32_t len);

// This function will return the number of bytes used by (pid, inout_type, transport_type). For example
// that way you can get the "outgoing udp bytes for pid 1234".
//
// Prividing NULL for...
//   ...pid_opt means all bytes/traffic that could not be assigned to a pid
//   ...inout_opt and tt_opt means the value can be arbitrary.
//
// Example: (1234, NULL, tcp) will return the number of bytes of the tcp traffic (incoming and outgoing) for pid 1234.
// Example: (1234, incoming, NULL) will return the number of bytes of the incoming traffic (tcp and udp) for pid 1234.
ni_error_code netinfo_stat_get_bytes_per_attr(ni_net_statistics s, ni_pid* pid_opt, ni_inout* inout_opt, ni_transport_type* tt_opt, uint64_t* bytes_out);

// "ni_net_statistics" is a pointer, so all "copies" of "s" are being invalidated by this function.
ni_error_code netinfo_free_stat(ni_net_statistics s);

// this function returns NULL on error (but that should not happen too often...)
const uint8_t* netinfo_get_error_description(ni_error_code error_code);

#ifdef __cplusplus
}
#endif

#endif // _NETINFO_HEADER_DEF_
