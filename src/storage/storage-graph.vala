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
    private bool is_root { get; private set; }

    public unowned GLib.ListStore model {
        get { return _model; }
        set {
            _model = value;
            this.draw.connect (draw_storage_graph);
            this.queue_draw ();
            is_root = false;

            for (int i = 0; i < value.get_n_items (); i++) {
                var item = model.get_item (i) as StorageViewItem;
                if (item.custom_type == StorageViewType.OS) {
                    is_root = true;
                    break;
                }
            }
        }
    }

    public uint min_percentage_shown_files { get; set; }

    class construct {
        set_css_name ("StorageGraph");
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
        uint shown_items_number = 1;
        var background_color = get_toplevel ().get_style_context ().get_background_color (get_toplevel ().get_style_context ().get_state ());
        var foreground_color = get_style_context ().get_color (get_style_context ().get_state ());

        for (int i = 1; i < model.get_n_items (); i++) {
            var item = (model.get_item (i) as StorageViewItem);

            if (i > 0 && i < 3 && (item.percentage < min_percentage_shown_files)) {
                shown_items_number = model.get_n_items ();
                continue;
            }

            if (item.percentage > min_percentage_shown_files)
                shown_items_number = shown_items_number + 1;
        }

        if (shown_items_number > 1) {
            if (shown_items_number < 3)
                shown_items_number = 3;

            for (int i = 0; i < model.get_n_items (); i++) {
                var item = model.get_item (i) as StorageViewItem;
                var item_radius = radius;
                if (item.custom_type == StorageViewType.UP_FOLDER || item.size == 0)
                    continue;

                var style_context = get_style_context ();
                style_context.add_class (item.style_class);
                var base_color = style_context.get_background_color (style_context.get_state ());
                style_context.remove_class (item.style_class);

                Gdk.RGBA fill_color = base_color;

                if (!is_root) {
                    fill_color = Utils.generate_color (base_color, i, shown_items_number, true);
                    item.color = fill_color;
                }

                if (selected_items.find (item) != null)
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
            context.line_to (x, y-(radius));
            context.stroke ();

            context.arc (x, y, radius/1.8, 0, 2 * Math.PI);
            Gdk.cairo_set_source_rgba (context, background_color);
            context.fill_preserve ();
            Gdk.cairo_set_source_rgba (context, foreground_color);
            context.stroke ();
        }
    }

    private bool draw_storage_graph (Cairo.Context context) {
        int height = this.get_allocated_height ();
        int width = this.get_allocated_width ();

        double x = 0;
        double y = 0;
        double radius = 0;

        radius = int.min (width, height) / 2.0;
        radius -= radius / 4;
        x = width / 2.0;
        y = height / 2.0;

        draw_circle (context, x, y, radius, 0, Circle.BASE);
        draw_selected_size_text (context);

        return true;
    }

    private void draw_selected_size_text (Cairo.Context context) {
        if (selected_size == 0)
            return;

        var layout = create_pango_layout (null);
        var text = Utils.format_size_values (selected_size);

        int height = get_allocated_height ();
        int width = get_allocated_width ();
        double radius = int.min (width, height) / 22;

        var text_color = get_toplevel ().get_style_context ().get_color (get_toplevel ().get_style_context ().get_state ());
        var text_color_string = "#%02x%02x%02x".printf (
            (uint)(Math.round (text_color.red*255)),
            (uint)(Math.round (text_color.green*255)),
            (uint)(Math.round (text_color.blue*255))).up ();

        var markup = "<span foreground='" + text_color_string + "' font='" + radius.to_string () + "'><b>" + text + "</b></span>";
        layout.set_markup (markup, -1);

        Pango.Rectangle layout_rect;
        layout.get_pixel_extents (null, out layout_rect);
        layout.set_alignment (Pango.Alignment.CENTER);

        var x = (width - layout_rect.width) / 2;
        var y = (height - layout_rect.height) / 2;
        get_style_context ().render_layout (context, x, y, layout);
    }
}
