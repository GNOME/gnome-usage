/* cpu-graph-model.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

using Dazzle;

namespace Usage {

    public class CpuGraphModel : GraphModel {
        public signal void big_process_usage (int column);
        public signal void small_process_usage (int column);
        private bool[] change_big_process_usage;
        private bool[] change_small_process_usage;

        public CpuGraphModel () {
            var settings = Settings.get_default();
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_total = new GraphColumn("TOTAL CPU", Type.from_name("gdouble"));
            add_column(column_total);

            change_big_process_usage = new bool[get_num_processors()];
            change_small_process_usage = new bool[get_num_processors()];

            for (int i = 0; i < get_num_processors(); i++) {
                var column_x_cpu = new GraphColumn("CPU: " + i.to_string(), Type.from_name("gdouble"));
                add_column(column_x_cpu);

                change_big_process_usage[i] = true;
                change_small_process_usage[i] = true;
            }

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data() {
            GraphModelIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = SystemMonitor.get_default();

            for (int i = 0; i < get_num_processors(); i++) {
                iter_set_value(iter, i, monitor.x_cpu_load[i]);

                if(monitor.x_cpu_load[i] >= 90) {
                    if(change_big_process_usage[i]) {
                        big_process_usage(i);
                        change_big_process_usage[i] = false;
                        change_small_process_usage[i] = true;
                    }
                }
                else {
                    if(change_small_process_usage[i]) {
                        small_process_usage(i);
                        change_small_process_usage[i] = false;
                        change_big_process_usage[i] = true;
                    }
                }
            }

            return true;
        }
    }

    public class CpuGraphModelMostUsedCore : GraphModel {
        public signal void big_process_usage ();
        public signal void small_process_usage ();
        private bool change_big_process_usage = true;
        private bool change_small_process_usage = true;

        public CpuGraphModelMostUsedCore () {
            var settings = Settings.get_default();
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column = new GraphColumn("MOST USED CORE", Type.from_name("gdouble"));
            add_column(column);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data() {
            GraphModelIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = SystemMonitor.get_default();
            double most_used_core = monitor.x_cpu_load[0];

            for (int i = 1; i < get_num_processors(); i++) {
                if(monitor.x_cpu_load[i] > most_used_core)
                    most_used_core = monitor.x_cpu_load[i];
            }

            iter_set_value(iter, 0, most_used_core);

            if(most_used_core >= 90) {
                if(change_big_process_usage) {
                    big_process_usage();
                    change_big_process_usage = false;
                    change_small_process_usage = true;
                }
            }
            else {
                if(change_small_process_usage) {
                    small_process_usage();
                    change_small_process_usage = false;
                    change_big_process_usage = true;
                }
            }

            return true;
        }
    }
}
