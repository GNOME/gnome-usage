/* cpu-graph.vala
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

/**
 *  Graph showing most used core
**/
public class Usage.CpuGraphMostUsedCore : GraphView {
    private Settings settings = Settings.get_default ();

    public CpuGraphMostUsedCore () {
        Graph max_load_graph = new Graph ();
        max_load_graph.maximal_queue_length = settings.graph_timespan/settings.graph_update_interval + 2;
        this.add_graph (max_load_graph);

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
            double most_used_core = monitor.x_cpu_load[0];

            for (int i = 1; i < get_num_processors (); i++) {
                if (monitor.x_cpu_load[i] > most_used_core)
                    most_used_core = monitor.x_cpu_load[i];
            }

            GraphPoint point = GraphPoint (timestamp, most_used_core);
            max_load_graph.push_point (point);

            return true;
        });
    }
}

/**
 *  Graph showing all processor cores.
**/
public class Usage.CpuGraph : GraphView {
    private Settings settings = Settings.get_default ();

    public CpuGraph () {
        for (int i = 0; i < get_num_processors (); i++) {
            Graph graph = new Graph ();
            graph.maximal_queue_length = settings.graph_timespan/settings.graph_update_interval + 2;
            this.add_graph (graph);
        }

        this.add_css_class ("big");

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

            for (int i = 0; i < get_num_processors (); i++) {
                GraphPoint point = GraphPoint (timestamp, monitor.x_cpu_load[i]);
                this.get_graph(i).push_point (point);
            }

            return true;
        });
    }
}
