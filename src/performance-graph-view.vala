/* performance-graph-view.vala
 *
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
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

public abstract class Usage.PerformanceGraphView : GraphView {
    private Settings settings = Settings.get_default ();

    construct {
        this.range_y = 100;
        this.offset_y = 0;
        this.range_x = 1000 * settings.graph_timespan;
        this.update_x_offset ();

        this.add_tick_callback (this.update_x_offset);

        Timeout.add (settings.graph_update_interval, () => {
            this.update_graphs ();
            return true;
        });
    }

    public void add_graph (Graph graph) {
        graph.maximal_queue_length = (int) Math.ceilf((float) settings.graph_timespan/settings.graph_update_interval) + 2;
        base.add_graph (graph);
    }

    public bool update_x_offset () {
        int64 timestamp = get_monotonic_time ();
        this.offset_x = timestamp - 1000 * (settings.graph_timespan + settings.graph_update_interval);
        return true;
    }

    protected abstract void update_graphs ();
}
