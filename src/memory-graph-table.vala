/* memory-graph-table.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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

using Rg;

namespace Usage {

    public class MemoryGraphTable : Rg.Table
    {
        public const int column_ram_id = 0;
        public const int column_swap_id = 1;
        public signal void big_ram_usage();
        public signal void small_ram_usage();
        private bool change_big_ram_usage = true;
        private bool change_small_ram_usage = true;

        public MemoryGraphTable ()
        {
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_ram = new Rg.Column("RAM", Type.from_name("gdouble"));
            add_column(column_ram);
            var column_swap = new Rg.Column("SWAP", Type.from_name("gdouble"));
            add_column(column_swap);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = SystemMonitor.get_default();
            double ram_usage = 0;
            if(monitor.ram_total != 0)
                ram_usage = (((double) monitor.ram_usage / monitor.ram_total) * 100);

            double swap_usage = 0;
            if(monitor.ram_total != 0)
                swap_usage = (((double) monitor.swap_usage / monitor.swap_total) * 100);

            iter.set (column_ram_id, ram_usage, -1);
            iter.set (column_swap_id, swap_usage, -1);

            if(ram_usage >= 90)
            {
                if(change_big_ram_usage)
                {
                    big_ram_usage();
                    change_big_ram_usage = false;
                    change_small_ram_usage = true;
                }
            }
            else
            {
                if(change_small_ram_usage)
                {
                    small_ram_usage();
                    change_small_ram_usage = false;
                    change_big_ram_usage = true;
                }
            }

            return true;
        }
    }
}
