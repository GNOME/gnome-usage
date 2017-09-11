/* disk-graph-model.vala
 *
 * Copyright (C) 2019 Red Hat, Inc.
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

    public class DiskGraphModel : GraphModel {
        public const int COLUMN_READ_ID = 0;
        public const int COLUMN_WRITE_ID = 1;

        private const double MIN_VALUE = 10;
        private const double GROW_UP_FACTOR = 1.5;
        private const double GROW_DOWN_LIMIT = 4;

        private double max_value = MIN_VALUE;

        construct {
            var settings = Settings.get_default();
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_download = new GraphColumn("READ", Type.from_name("gdouble"));
            add_column(column_download);
            var column_upload = new GraphColumn("WRITE", Type.from_name("gdouble"));
            add_column(column_upload);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data() {
            GraphModelIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = SystemMonitor.get_default();

            double disk_read = monitor.disk_read;
            double disk_write = monitor.disk_write;

            iter_set_value(iter, COLUMN_READ_ID, disk_read);
            iter_set_value(iter, COLUMN_WRITE_ID, disk_write);

            double max_iter_value_read = get_max_iter_val(COLUMN_READ_ID);
            double max_iter_value_write = get_max_iter_val(COLUMN_WRITE_ID);
            double max_actual_iter_value = max_iter_value_read > max_iter_value_write ? max_iter_value_read : max_iter_value_write;

            if(max_actual_iter_value > max_value || max_actual_iter_value < (max_value / GROW_DOWN_LIMIT))
                max_value = max_actual_iter_value * GROW_UP_FACTOR;

            if(max_value < MIN_VALUE)
                max_value = MIN_VALUE;

            this.value_max = max_value;

            return true;
        }

        double get_max_iter_val (uint column_index) {
            double max_value = 0.0;
            GraphModelIter iter;

            if (get_iter_first (out iter)) {
                var val = iter_get_value(iter, column_index);
                max_value = val.get_double();

                while (iter_next (ref iter)) {
                    var val_next = iter_get_value(iter, column_index);
                    max_value = val_next.get_double() > max_value ? val_next.get_double() : max_value;
                }
            }

            return max_value;
        }
    }
}
