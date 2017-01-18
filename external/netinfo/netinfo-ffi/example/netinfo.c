/* IMPORTANT: This is just an example - this code will not be part of the libnetinfo.so */
#include "netinfo.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void handle_error(ni_error_code e) {
  if(e < 0) { printf("NETINFO ERROR: %s\n", netinfo_get_error_description(e)); exit(1); }
}

void print_net_interface_info(ni_net_interface i) {
  uint8_t* name = 0;
  uint32_t name_len = 0;
  ni_error_code e = netinfo_int_get_name(i, &name, &name_len);
  if(e < 0) { printf("%s\n", netinfo_get_error_description(e)); exit(1); }
  printf("Network interface: %s\n", name);
  netinfo_free_string(name, name_len);

  fflush(stdout);

  ni_ipv4_addr* ipv4_addr = 0;
  uint32_t num_ipv4_addr = 0;
  ni_ipv6_addr* ipv6_addr = 0;
  uint32_t num_ipv6_addr = 0;
  netinfo_int_get_ips(i, &ipv4_addr, &num_ipv4_addr, &ipv6_addr, &num_ipv6_addr);

  for(uint32_t i = 0; i < num_ipv4_addr; i++) {
    ni_ipv4_addr ip = ipv4_addr[i];
    printf("Ipv4: %d.%d.%d.%d\n", ip.d[0], ip.d[1], ip.d[2], ip.d[3]);
  }

  for(uint32_t i = 0; i < num_ipv6_addr; i++) {
    ni_ipv6_addr ip = ipv6_addr[i];
    printf("Ipv6: %02X%02X", ip.d[0], ip.d[1], ip.d[2], ip.d[3]);
    for(int i = 1; i < 8; i++) printf("::%02X%02X", ip.d[i * 2 + 0], ip.d[i * 2 + 1]);
    printf("\n");
  }

  printf("\n");

  netinfo_free_ip_arrays(ipv4_addr, num_ipv4_addr, ipv6_addr, num_ipv6_addr);
}

void handle_thread_errors(ni_netinfo netinfo) {
  ni_error_code* errors = 0;
  uint32_t num_errors = 0;
  handle_error(netinfo_pop_thread_errors(netinfo, &errors, &num_errors));
  if(num_errors > 0) { handle_error(errors[0]); }
  handle_error(netinfo_free_thread_error_array(errors, num_errors));
}

void get_net_stat(ni_netinfo netinfo) {
    ni_net_statistics stat; memset(&stat, 0, sizeof(ni_net_statistics));
    handle_error(netinfo_get_net_statistics(netinfo, &stat));

    ni_pid* pids = 0;
    uint32_t num_pids = 0;
    handle_error(netinfo_stat_get_all_pids(stat, &pids, &num_pids));
    for(uint32_t i = 0; i < num_pids; i++) {
      uint64_t bytes = 1;
      handle_error(netinfo_stat_get_bytes_per_pid(stat, pids[i], &bytes));
      printf("Pid %d: %d bytes\n", pids[i], bytes);

    }
    handle_error(netinfo_free_pid_array(pids, num_pids));

    handle_error(netinfo_free_stat(stat));
}

int main() {
  uint32_t num_net_interfaces = 0;
  ni_net_interface* net_interfaces_arrary = NULL;
  ni_error_code e;

  // get all network interfaces that netinfo can work with
  e = netinfo_list_net_interface(&net_interfaces_arrary, &num_net_interfaces);
  handle_error(e);
  for(uint32_t i = 0; i < num_net_interfaces; i++) { print_net_interface_info(net_interfaces_arrary[i]); }


  // initialize our netinfo object to capture traffic
  ni_netinfo netinfo; memset(&netinfo, 0, sizeof(ni_netinfo));
  e = netinfo_init(net_interfaces_arrary, num_net_interfaces, &netinfo);
  handle_error(e);
  e = netinfo_free_net_interface_array(net_interfaces_arrary, num_net_interfaces); // this is safe; "netinfo_init()" does not keep references
  handle_error(e);

  // start capturing
  handle_error(netinfo_set_min_refresh_interval(netinfo, 1, 100));
  handle_error(netinfo_start(netinfo));

  uint32_t second = 0;
  while(1) {
    handle_thread_errors(netinfo);
    get_net_stat(netinfo);
    handle_error(netinfo_clear(netinfo));

    sleep(1);
    printf("<------- second %d ------>\n", second);
    second++;

  }

  // clean up
  netinfo_free(netinfo);
}
