/* network-view.vala
 *
 * Copyright (C) 2023–2025 Markus Göllnitz
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

[GtkTemplate (ui = "/org/gnome/Usage/ui/network-view.ui")]
public class Usage.NetworkView : Usage.View {
    private const int64 DAY = 24 * 60 * 60;

    [GtkChild]
    private unowned Adw.ViewStack interface_graphs;

    construct {
        name = "NETWORK";
        title = _("Network");
        icon_name = "network-transmit-receive-symbolic";
        search_available = false;
        switcher_widget = null;
    }

    public NetworkView () {
        HashTable<string, NM.Device> devices = new HashTable<string, NM.Device> (GLib.str_hash, GLib.str_equal);
        uint ethernet_count = 0, wifi_count = 0, p2p_count = 0, modem_count = 0, bt_count = 0;

        try {
            NM.Client nm_client = new NM.Client ();

            foreach (NM.Device device in nm_client.devices) {
                if (device.@interface != null && (!devices.contains (device.@interface) || device.managed)) {
                    devices.insert (device.@interface, device);
                }
                if (device.ip_interface != null && (!devices.contains (device.ip_interface) || device.managed)) {
                    devices.insert (device.ip_interface, device);
                }
            }
        } catch (Error error) {
            info ("Error with NetworkManager: %s\n", error.message);
        }

        foreach (Vnstat.Interface iface in Vnstat.list_interfaces ()) {
            List<Vnstat.TrafficDataPoint?> interface_daily_data = iface.get_traffic (Vnstat.Mode.DAILY);

            /* interfaces with no data available are often temporary */
            if (!iface.recently_used) {
                continue;
            }

            string interface_name = iface.name;
            NM.Device? device = devices[interface_name];
            NetworkInterfaceGraph interface_view = new NetworkInterfaceGraph ();

            string title = interface_name;
            if (device == null) {
                warning ("skipping unknown interface “%s”", interface_name);
                continue;
            } else {
                /* possibly use device.udi, device.vendor, device.product if too simple */
                switch (((!) device).device_type) {
                    case NM.DeviceType.ETHERNET:
                        ethernet_count++;
                        title = _("Wired");
                        if (ethernet_count > 1) {
                            title += @" $ethernet_count";
                        }
                        break;
                    case NM.DeviceType.WIFI:
                        wifi_count++;
                        title = _("WiFi");
                        if (wifi_count > 1) {
                            title += @" $wifi_count";
                        }
                        break;
                    case NM.DeviceType.WIFI_P2P:
                        p2p_count++;
                        title = _("WiFi (Peer to Peer)");
                        if (p2p_count > 1) {
                            title += @" $p2p_count";
                        }
                        break;
                    case NM.DeviceType.MODEM:
                        modem_count++;
                        title = _("Mobile Connection");
                        if (modem_count > 1) {
                            title += @" $modem_count";
                        }
                        break;
                    case NM.DeviceType.BT:
                        bt_count++;
                        title = _("Bluetooth Hotspot");
                        if (bt_count > 1) {
                            title += @" $bt_count";
                        }
                        break;
                    default:
                        info ("including interface “%s” of unknown type %i", interface_name, ((!) device).device_type);
                        break;
                }
            }

            int64 start_timestamp = DAY * ((int64) ((get_real_time () / 1000000) / DAY) - 30);
            double max_val = 1;
            foreach (Vnstat.TrafficDataPoint? nullable_data_point in interface_daily_data) {
                if (nullable_data_point == null) {
                    continue;
                }
                Vnstat.TrafficDataPoint data_point = (!) nullable_data_point;

                GraphPoint download_point = GraphPoint (data_point.timestamp, data_point.download);
                GraphPoint upload_point = GraphPoint (data_point.timestamp, data_point.upload);

                interface_view.download_graph.push_point (download_point);
                interface_view.upload_graph.push_point (upload_point);

                if (data_point.timestamp >= start_timestamp) {
                    max_val = Math.fmax (Math.fmax (data_point.download, data_point.upload), max_val);
                }
            }

            interface_graphs.add_titled_with_icon (interface_view,
                                                   interface_name,
                                                   title,
                                                   "network-transmit-receive-symbolic");

            interface_view.set_ranges (start_timestamp, start_timestamp + (30 * DAY), (int64) max_val);
        }
    }

    public override bool prerequisite_fulfilled () {
        return Vnstat.test_exists ();
    }
}
