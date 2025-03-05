/* storage-graph.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
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

using Gtk;

public class Usage.StorageGraph : Gtk.DrawingArea {
    private unowned List<StorageViewItem> selected_items;
    private unowned GLib.ListStore _model;
    private uint64 selected_size = 0;

    public virtual GLib.ListStore model {
        get { return _model; }
        set {
            _model = value;
            value.items_changed.connect (this.queue_draw);
            this.queue_draw ();
        }
    }

    public uint min_percentage_shown_files { get; set; }

    class construct {
        set_css_name ("StorageGraph");
    }

    construct {
        this.set_draw_func (draw_storage_graph);
    }

    public enum Circle {
        HOME,
        ROOT,
        BASE
    }

    public void update_selected_items (List<StorageViewItem> selected_items) {
        this.selected_items = selected_items;

        uint64 size = 0;
        foreach (var item in selected_items)
            size += item.size;

        selected_size = size;
        this.queue_draw ();
    }

    private void draw_circle (Cairo.Context context, double x, double y, double radius, int section, Circle circle) {
        double start_angle = 0;
        double final_angle = - Math.PI / 2.0;
        double ratio = 0;
        Gdk.RGBA background_color;
        this.get_style_context ().lookup_color ("window_bg_color", out background_color);
        Gdk.RGBA foreground_color = this.get_color ();

        for (int i = 0; i < this.model.get_n_items (); i++) {
            StorageViewItem item = (StorageViewItem) this.model.get_item (i);

            if (item.custom_type == StorageViewType.UP_FOLDER || item.size == 0)
                continue;

            double item_radius = radius;
            Gdk.RGBA fill_color = item.color;

            if (this.selected_items.find (item) != null)
                item_radius += radius / 6;

            context.set_line_width (2.0);
            start_angle = final_angle;

            if (item.percentage < 0.3)
                ratio = ratio + ((double) 0.3 / 100);
            else
                ratio = ratio + ((double) item.percentage / 100);

            final_angle = ratio * 2 * Math.PI - Math.PI / 2.0;
            if (final_angle >= (2 * Math.PI - Math.PI / 2.0))
                final_angle = 2 * Math.PI - Math.PI / 2.0;

            context.move_to (x, y);
            Gdk.cairo_set_source_rgba (context, fill_color);
            context.arc (x, y, item_radius, start_angle, final_angle);
            context.line_to (x, y);
            context.fill_preserve ();
            Gdk.cairo_set_source_rgba (context, foreground_color);
            context.stroke ();

            if (start_angle >= (2 * Math.PI - Math.PI / 2.0))
                break;
        }

        context.move_to (x, y);
        context.line_to (x, y - radius);
        context.stroke ();

        context.arc (x, y, radius / 1.8, 0, 2 * Math.PI);
        Gdk.cairo_set_source_rgba (context, background_color);
        context.fill_preserve ();
        Gdk.cairo_set_source_rgba (context, foreground_color);
        context.stroke ();
    }

    private void draw_storage_graph (Gtk.DrawingArea drawing_area, Cairo.Context context, int width, int height) {
        double x = 0;
        double y = 0;
        double radius = 0;

        radius = int.min (width, height) / 2.0;
        radius -= radius / 4;
        x = width / 2.0;
        y = height / 2.0;

        draw_circle (context, x, y, radius, 0, Circle.BASE);
        draw_selected_size_text (context);
    }

    private void draw_selected_size_text (Cairo.Context context) {
        if (selected_size == 0)
            return;

        var layout = create_pango_layout (null);
        var text = Utils.format_size_values (selected_size);

        int height = this.get_height ();
        int width = this.get_width ();
        double radius = int.min (width, height) / 22;

        var text_color = this.get_root ().get_color ();
        var text_color_string = "#%02x%02x%02x".printf (
            (uint) (Math.round (text_color.red * 255)),
            (uint) (Math.round (text_color.green * 255)),
            (uint) (Math.round (text_color.blue * 255))).up ();

        var markup = @"<span foreground='$text_color_string' font='$radius'><b>$text</b></span>";
        layout.set_markup (markup, -1);

        Pango.Rectangle layout_rect;
        layout.get_pixel_extents (null, out layout_rect);
        layout.set_alignment (Pango.Alignment.CENTER);

        var x = (width - layout_rect.width) / 2;
        var y = (height - layout_rect.height) / 2;
        get_style_context ().render_layout (context, x, y, layout);
    }
}
