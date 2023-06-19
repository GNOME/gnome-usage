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

namespace Vnstat {

    public enum Mode {
        HOURLY = 'h',
        DAILY = 'd',
        MONTHLY = 'm',
        TOP = 't',
    }

    public bool test_exists () {
        bool exists = false;

        string vnstat_stdout;
        string vnstat_stderr;
        int vnstat_status;

        try {
            GLib.Process.spawn_command_line_sync ("vnstat --json",
                                                  out vnstat_stdout,
                                                  out vnstat_stderr,
                                                  out vnstat_status);

            Json.Object? vnstat_json = Json.from_string (vnstat_stdout)?.get_object ();

            exists = vnstat_json?.get_string_member ("jsonversion") == "2";
        } catch (SpawnError error) {
            info ("Error connecting to vnstat: %s\n", error.message);
        } catch (Json.ParserError error) {
            info ("Error parsing vnstat's result: %s\n", error.message);
        } catch (Error error) {
            info ("Error with vnstat: %s\n", error.message);
        }

        return exists;
    }

    public Interface[] list_interfaces () {
        Interface[] interfaces = {};

        string vnstat_stdout;
        string vnstat_stderr;
        int vnstat_status;

        try {
            GLib.Process.spawn_command_line_sync ("vnstat --json",
                                                  out vnstat_stdout,
                                                  out vnstat_stderr,
                                                  out vnstat_status);

            Json.Object? vnstat_json = Json.from_string (vnstat_stdout)?.get_object ();

            List<weak Json.Node>? interface_list = vnstat_json?.get_array_member ("interfaces")?.get_elements ();
            if (interface_list != null) {
                foreach (Json.Node interface_element in (!) interface_list) {
                    Json.Object interface_json = (!) interface_element.get_object ();
                    string interface_name = interface_json.get_string_member_with_default ("name", "");
                    interfaces += new Interface (interface_name);
                }
            }
        } catch (SpawnError error) {
            info ("Error connecting to vnstat: %s\n", error.message);
        } catch (Json.ParserError error) {
            info ("Error parsing vnstat's result: %s\n", error.message);
        } catch (Error error) {
            info ("Error with vnstat: %s\n", error.message);
        }

        return interfaces;
    }

    public struct TrafficDataPoint {
        public int64 timestamp;
        public double download;
        public double upload;
    }

    public class Interface {
        public string name { get; private set; }
        public bool recently_used { get; private set; }

        public Interface (string name) {
            this.name = name;
        }

        public List<TrafficDataPoint?> get_traffic (Vnstat.Mode mode) {
            List<TrafficDataPoint?> traffic = new List<TrafficDataPoint?> ();

            string vnstat_stdout;
            string vnstat_stderr;
            int vnstat_status;

            try {
                GLib.Process.spawn_command_line_sync (@"vnstat --json $mode -i $name",
                                                      out vnstat_stdout,
                                                      out vnstat_stderr,
                                                      out vnstat_status);

                if (vnstat_status == 0) {
                    Json.Object? vnstat_json = Json.from_string (vnstat_stdout)?.get_object ();

                    List<weak Json.Node>? interface_list = vnstat_json?.get_array_member ("interfaces")?.get_elements ();
                    if (interface_list != null) {
                        foreach (Json.Node interface_element in (!) interface_list) {
                            Json.Object? interface_json = interface_element.get_object ();
                            string member_name = "";

                            switch (mode) {
                                case Mode.HOURLY:
                                    member_name = "hour";
                                    break;
                                case Mode.DAILY:
                                    member_name = "day";
                                    break;
                                case Mode.MONTHLY:
                                    member_name = "month";
                                    break;
                                case Mode.TOP:
                                    member_name = "top";
                                    break;
                            }

                            Json.Array? traffic_json = interface_json?.get_object_member ("traffic")?.get_array_member (member_name);

                            traffic_json?.foreach_element ((data_point_array, data_point_index, data_point_element) => {
                                Json.Object data_point_json = (!) data_point_element.get_object ();

                                traffic.append (TrafficDataPoint () {
                                    timestamp = data_point_json.get_int_member ("timestamp"),
                                    download = data_point_json.get_int_member ("rx"),
                                    upload = data_point_json.get_int_member ("tx"),
                                });
                            });

                            this.recently_used = traffic_json?.get_length () != 0;
                        }
                    }
                }
            } catch (SpawnError error) {
                info ("Error connecting to vnstat: %s\n", error.message);
            } catch (Json.ParserError error) {
                info ("Error parsing vnstat's result: %s\n", error.message);
            } catch (Error error) {
                info ("Error with vnstat: %s\n", error.message);
            }

            return (owned) traffic;
        }
    }

}
