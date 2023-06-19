/* network-interface-graph.vala
 *
 * Copyright (C) 2023–2025 Markus Göllnitz
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

public class Usage.NetworkInterfaceGraph : Adw.Bin {
    public Graph download_graph {
        get; private set; default = new Graph () {
            color = Gdk.RGBA () { red = 46f / 255f, green = 194f / 255f, blue = 126f / 255f, alpha = 1f },
        };
    }
    public Graph upload_graph {
        get; private set; default = new Graph () {
            color = Gdk.RGBA () { red = 192f / 255f, green = 97f / 255f, blue = 203f / 255f, alpha = 1f },
        };
    }
    public GraphView graph_view { get; private set; default = new GraphView (); }

    public static Gtk.SizeGroup y_labels_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);

    private Gtk.Label y_label_max;
    private Gtk.Label t_label_min;
    private Gtk.Label t_label_max;

    public NetworkInterfaceGraph () {
        graph_view.add_css_class ("big");
        graph_view.add_graph (download_graph);
        graph_view.add_graph (upload_graph);

        var network_graph_box = new GraphBox (graph_view);
        network_graph_box.height_request = 225;
        network_graph_box.valign = Gtk.Align.START;
        network_graph_box.add_css_class ("card");

        Gtk.Label y_label_min = new Gtk.Label (Utils.format_size_values (0));
        y_label_max = new Gtk.Label ("…");
        Gtk.Box y_labels = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        y_labels_group.add_widget (y_labels);
        y_labels.append (y_label_max);
        y_labels.append (y_label_min);
        y_label_min.xalign = 1;
        y_label_max.xalign = 1;
        y_label_max.vexpand = true;
        y_label_max.valign = Gtk.Align.START;

        Gtk.Box timestamp_labels = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        t_label_min = new Gtk.Label ("…");
        t_label_min.hexpand = true;
        t_label_min.halign = Gtk.Align.START;
        t_label_max = new Gtk.Label ("…");
        t_label_max.hexpand = true;
        t_label_max.halign = Gtk.Align.END;
        timestamp_labels.append (t_label_min);
        timestamp_labels.append (t_label_max);

        Gtk.Grid network_box = new Gtk.Grid ();
        network_box.column_spacing = 6;
        network_box.row_spacing = 6;
        network_box.valign = Gtk.Align.START;
        network_box.attach (y_labels, 0, 0, 1, 1);
        network_box.attach (network_graph_box, 1, 0, 1, 1);
        network_box.attach (timestamp_labels, 1, 1, 1, 1);

        this.child = network_box;
    }

    public void set_ranges (int64 min_timestamp, int64 max_timestamp, int64 max_val) {
        DateTime start_date = new DateTime.from_unix_local (min_timestamp);
        DateTime end_date = new DateTime.from_unix_local (max_timestamp);

        this.graph_view.offset_x = min_timestamp;
        this.graph_view.offset_y = 0;
        this.graph_view.range_x = max_timestamp - min_timestamp;
        this.graph_view.range_y = (int64) max_val;

        y_label_max.label = Utils.format_size_values (graph_view.range_y);
        t_label_min.label = start_date.format (_("%b %e, %Y"));
        t_label_max.label = end_date.format (_("%b %e, %Y"));
    }
}
