/* graph.vala
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

public class Usage.GraphView : Gtk.Widget {
    private Gee.ArrayList<Usage.Graph> graphs = new Gee.ArrayList<Usage.Graph> ();

    public int64 _offset_x = 0;
    public int64 _range_x = 1;
    public int64 _offset_y = 0;
    public int64 _range_y = 1;

    public virtual int64 offset_x {
        get { return _offset_x; }
        set {
            _offset_x = value;
            this.queue_draw ();
        }
    }
    public int64 range_x {
        get { return _range_x; }
        set {
            _range_x = value;
            this.queue_draw ();
        }
    }
    public int64 offset_y {
        get { return _offset_y; }
        set {
            _offset_y = value;
            this.queue_draw ();
        }
    }
    public int64 range_y {
        get { return _range_y; }
        set {
            _range_y = value;
            this.queue_draw ();
        }
    }

    class construct {
        set_css_name ("rg-graph");
    }

    construct {
        this.overflow = Gtk.Overflow.HIDDEN;
    }

    public void add_graph (Graph graph) {
        this.graphs.add (graph);
        graph.updated.connect (this.queue_draw);
        this.queue_draw ();
    }

    public void remove_graph (Graph graph) {
        this.graphs.remove (graph);
        graph.updated.disconnect (this.queue_draw);
        this.queue_draw ();
    }

    public Graph get_graph (int i) {
        return this.graphs.@get (i);
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        float thickness = 2.5f;

        int view_width = this.get_width ();
        int view_height = (int) Math.llrintf (this.get_height () - thickness);

        foreach (Graph graph in graphs) {
            Gdk.RGBA color;
            if (graph.color != null) {
                color = (!) graph.color;
            } else {
                color = Adw.StyleManager.get_default ().get_accent_color ().to_rgba ();
            }
            Gdk.RGBA color_transparent = color.copy ();
            color_transparent.alpha = 0;

            Gsk.ColorStop[] stops = {
                Gsk.ColorStop () { offset = 0, color = color_transparent },
                Gsk.ColorStop () { offset = 0.3f, color = color },
                Gsk.ColorStop () { offset = 0.7f, color = color },
                Gsk.ColorStop () { offset = 1, color = color_transparent },
            };

            for (uint n = 1; n < graph.values.get_length (); n++) {
                GraphPoint graph_point = graph.values.peek_nth (n);
                GraphPoint graph_point_next = graph.values.peek_nth (n - 1);

                double delta_x = (double) (graph_point_next.timestamp - graph_point.timestamp) * view_width / range_x;
                double delta_y = (graph_point_next.level - graph_point.level)  * view_height / range_y;

                float x = (float) (graph_point.timestamp - offset_x) * view_width / range_x;
                float y = (offset_y + range_y - (float) graph_point.level) * view_height / range_y + thickness/2;

                double angle = Math.atan2(delta_y, delta_x);
                double sin_angle;
                double cos_angle;
                Math.sincos(angle, out sin_angle, out cos_angle);

                Graphene.Rect bounds = Graphene.Rect ();
                bounds.init (x, Math.fminf(y, y - (float) delta_y) - thickness/2, (float) delta_x, Math.fabsf((float) delta_y) + thickness);

                Graphene.Point start = Graphene.Point ();
                Graphene.Point end = Graphene.Point ();
                start.init (x - thickness/2 * (float) sin_angle, y - thickness/2 * (float) cos_angle);
                end.init (x + thickness/2 * (float) sin_angle, y + thickness/2 * (float) cos_angle);

                snapshot.append_linear_gradient (bounds, start, end, stops);
            }
        }
    }
}

public class Usage.Graph {
    public Gsk.RenderNode render_node;
    public Queue<GraphPoint?> values = new Queue<GraphPoint?> ();
    public uint maximal_queue_length = 0;
    public Gdk.RGBA? color = null;

    public void push_point (GraphPoint point) {
        this.values.push_head (point);
        if (maximal_queue_length > 0) {
            while (this.values.get_length () > maximal_queue_length) {
                this.values.pop_tail ();
            }
        }
        this.updated ();
    }

    public signal void updated ();
}

public struct Usage.GraphPoint {
    int64 timestamp;
    double level;

    public GraphPoint (int64 timestamp, double level) {
        this.timestamp = timestamp;
        this.level = level;
    }
}
