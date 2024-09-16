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

public class Usage.MemoryGraph : PerformanceGraphView {
    Graph mem_graph = new Graph ();
    Graph swap_graph = new Graph ();

    public MemoryGraph () {
        this.add_graph (this.mem_graph);
        this.add_graph (this.swap_graph);
    }

    protected override void update_graphs () {
        SystemMonitor monitor = SystemMonitor.get_default ();
        int64 timestamp = get_monotonic_time ();

        double ram_usage = 0;
        if (monitor.ram_total != 0)
            ram_usage = (double) monitor.ram_usage / monitor.ram_total;

        GraphPoint mem_point = GraphPoint (timestamp, ram_usage);
        mem_graph.push_point (mem_point);

        if (monitor.swap_total != 0) {
            double swap_usage = (double) monitor.swap_usage / monitor.swap_total;

            GraphPoint swap_point = GraphPoint (timestamp, swap_usage);
            swap_graph.push_point (swap_point);
        }
    }
}
