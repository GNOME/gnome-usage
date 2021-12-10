/* color-rectangle.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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

public class Usage.ColorRectangle : Gtk.DrawingArea {
    public Gdk.RGBA color { get; set; }

    class construct {
        set_css_name ("ColorRectangle");
    }

    construct {
        this.height_request = 17;
        this.width_request = 17;
        this.valign = Gtk.Align.CENTER;
        this.draw.connect ((context) => {
            int height = this.get_allocated_height ();
            int width = this.get_allocated_width ();

            double degrees = Math.PI / 180.0;
            double x = 0;
            double y = 0;
            double radius = height / 5;

            context.new_sub_path ();
            context.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
            context.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
            context.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
            context.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
            context.close_path ();

            Gdk.cairo_set_source_rgba (context, color);
            context.fill ();
            return true;
        });
    }

    public ColorRectangle.new_from_rgba (Gdk.RGBA color) {
        this.color = color;
        queue_draw_area (0, 0, this.get_allocated_width (), this.get_allocated_height ());
    }

    public ColorRectangle.new_from_css (string css_class) {
        set_color_from_css (css_class);
    }

    public void set_color_from_css (string css_class) {
        get_style_context ().add_class (css_class);
        color = get_style_context ().get_color (get_style_context ().get_state ());
        queue_draw_area (0, 0, this.get_allocated_width (), this.get_allocated_height ());
    }
}
