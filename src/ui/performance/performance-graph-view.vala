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
    private bool constant_redraw;

    construct {
        Settings settings = new Settings ();

        this.range_y = 1;
        this.offset_y = 0;
        this.range_x = 1000 * settings.graph_timespan;
        this.update_x_offset ();

        this.reevaluate_constant_redraw ();
        settings.notify["enable-scrolling-graph"].connect (this.reevaluate_constant_redraw);
        new SystemMonitor ().updated.connect (this.update_graphs);
    }

    private void reevaluate_constant_redraw () {
        this.constant_redraw = new Settings ().enable_scrolling_graph;

        if (this.constant_redraw) {
            this.add_tick_callback (this.queue_update);
            new SystemMonitor ().updated.disconnect (this.update_x_offset);
        } else {
            new SystemMonitor ().updated.connect (this.update_x_offset);
        }
    }

    private bool queue_update () {
        this.update_x_offset ();
        return this.constant_redraw;
    }

    public new void add_graph (Graph graph) {
        Settings settings = new Settings ();
        float visible_points = (float) settings.graph_timespan / settings.data_update_interval + 1;
        graph.maximal_queue_length = (int) Math.ceilf (visible_points);
        base.add_graph (graph);
    }

    public void update_x_offset () {
        Settings settings = new Settings ();
        int64 timestamp = get_monotonic_time ();
        int64 offset = timestamp - 1000 * settings.graph_timespan;
        if (constant_redraw) {
            offset -= 1000 * settings.data_update_interval;
        }
        this.offset_x = offset;
    }

    protected abstract void update_graphs ();
}
