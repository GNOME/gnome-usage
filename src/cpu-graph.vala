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
public class Usage.CpuGraphMostUsedCore : PerformanceGraphView {
    Graph max_load_graph = new Graph ();

    public CpuGraphMostUsedCore () {
        this.add_graph (this.max_load_graph);
    }

    protected override void update_graphs () {
        SystemMonitor monitor = SystemMonitor.get_default ();
        int64 timestamp = get_monotonic_time ();
        double most_used_core = monitor.x_cpu_load[0];

        for (int i = 1; i < get_num_processors (); i++) {
            if (monitor.x_cpu_load[i] > most_used_core)
                most_used_core = monitor.x_cpu_load[i];
        }

        GraphPoint point = GraphPoint (timestamp, most_used_core);
        max_load_graph.push_point (point);
    }
}

/**
 *  Graph showing all processor cores.
**/
public class Usage.CpuGraph : PerformanceGraphView {
    public CpuGraph () {
        for (int i = 0; i < get_num_processors (); i++) {
            Graph graph = new Graph ();
            this.add_graph (graph);
        }

        this.add_css_class ("big");
    }

    protected override void update_graphs () {
        SystemMonitor monitor = SystemMonitor.get_default ();
        int64 timestamp = get_monotonic_time ();

        for (int i = 0; i < get_num_processors (); i++) {
            GraphPoint point = GraphPoint (timestamp, monitor.x_cpu_load[i]);
            this.get_graph(i).push_point (point);
        }
    }
}
