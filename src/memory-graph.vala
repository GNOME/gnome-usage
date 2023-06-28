/* memory-graph.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
 * Copyright (C) 2023 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.MemoryGraph : GraphView {
    private Settings settings = Settings.get_default ();

    public MemoryGraph () {
        Graph mem_graph = new Graph ();
        mem_graph.maximal_queue_length = settings.graph_timespan/settings.graph_update_interval + 2;
        this.add_graph (mem_graph);
        Graph swap_graph = new Graph ();
        swap_graph.maximal_queue_length = settings.graph_timespan/settings.graph_update_interval + 2;
        this.add_graph (swap_graph);

        this.range_y = 100;
        this.offset_y = 0;
        this.range_x = 1000 * settings.graph_timespan;
        this.add_tick_callback ((widget, frame_clock) => {
            int64 timestamp = get_monotonic_time ();
            this.offset_x = timestamp - 1000 * (settings.graph_timespan + settings.graph_update_interval);
            return true;
        });

        Timeout.add (settings.graph_update_interval, () => {
            SystemMonitor monitor = SystemMonitor.get_default ();
            int64 timestamp = get_monotonic_time ();

            double ram_usage = 0;
            if (monitor.ram_total != 0)
                ram_usage = (((double) monitor.ram_usage / monitor.ram_total) * 100);

            double swap_usage = 0;
            if (monitor.ram_total != 0)
                swap_usage = (((double) monitor.swap_usage / monitor.swap_total) * 100);

            GraphPoint mem_point = GraphPoint (timestamp, ram_usage);
            mem_graph.push_point (mem_point);
            GraphPoint swap_point = GraphPoint (timestamp, swap_usage);
            swap_graph.push_point (swap_point);

            return true;
        });
    }
}
