/* storage-graph.vala
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

namespace Usage
{
    public class StorageGraph : Gtk.DrawingArea
    {
        public const uint MIN_PERCENTAGE_SHOWN_FILES = 2;

        class construct
        {
            set_css_name("StorageGraph");
        }

        public StorageGraph()
        {
            this.draw.connect(draw_storage_graph);
        }

        public enum Circle
        {
            HOME,
            ROOT,
            BASE
        }

        private void draw_circle(Cairo.Context context, GLib.ListStore model, double x, double y, double radius, int section, Circle circle)
        {
            double start_angle = 0;
            double final_angle = - Math.PI / 2.0;
            double ratio = 0;
            var fill_color = Gdk.RGBA();
            var background_color = get_toplevel().get_style_context().get_background_color(get_toplevel().get_style_context().get_state());

            for(int i = 0; i < model.get_n_items(); i++)
            {
                StorageItem item = (StorageItem) model.get_item(i);
                if(item.get_percentage() > 0 && item.get_item_type() != StorageItemType.STORAGE && item.get_section() == section)
                {
                    var style_context = get_style_context();
                    switch(item.get_item_type())
                    {
                        case StorageItemType.SYSTEM:
                            style_context.add_class("system");
                            fill_color = style_context.get_color(style_context.get_state());
                            style_context.remove_class("system");
                            break;
                        case StorageItemType.TRASH:
                            style_context.add_class("trash");
                            fill_color = style_context.get_color(style_context.get_state());
                            style_context.remove_class("trash");
                            break;
                        case StorageItemType.USER:
                            style_context.add_class("user");
                            fill_color = style_context.get_color(style_context.get_state());
                            style_context.remove_class("user");
                            break;
                        case StorageItemType.AVAILABLE:
                            style_context.add_class("available-storage");
                            fill_color = style_context.get_color(style_context.get_state());
                            style_context.remove_class("available-storage");
                            break;
                        case StorageItemType.DOCUMENTS:
                        case StorageItemType.DOWNLOADS:
                        case StorageItemType.DESKTOP:
                        case StorageItemType.MUSIC:
                        case StorageItemType.PICTURES:
                        case StorageItemType.VIDEOS:
                        case StorageItemType.DIRECTORY:
                        case StorageItemType.FILE:
                            fill_color = item.get_color();
                            break;
                    }
                    context.set_line_width (2.0);
                    start_angle = final_angle;
                    ratio = ratio + ((double) item.get_percentage() / 100);
                    final_angle = ratio * 2 * Math.PI - Math.PI / 2.0;
                    context.move_to (x, y);
                    Gdk.cairo_set_source_rgba (context, fill_color);
                    context.arc (x, y, radius, start_angle, final_angle);
                    if(item.get_percentage() == 100)
                        context.fill();
                    else
                        context.fill_preserve();
                    Gdk.cairo_set_source_rgba (context, background_color);
                    context.stroke();

                    if(item.get_percentage() > MIN_PERCENTAGE_SHOWN_FILES)
                    {
                        double midle_angle = start_angle + (final_angle - start_angle) / 2;
                        midle_angle += Math.PI / 2;
                        double distance = radius + radius/10;
                        double x_text = 0;
                        double y_text = 0;
                        CornerType quadrant = 0;

                        if(midle_angle <= Math.PI / 2)
                        {
                            x_text = Math.sin(midle_angle) * distance;
                            x_text += x;
                            y_text = Math.cos(midle_angle) * distance;
                            y_text = y - y_text;
                            quadrant = CornerType.TOP_RIGHT;
                        }
                        else if (midle_angle <= Math.PI)
                        {
                            midle_angle = Math.PI - midle_angle;
                            x_text = Math.sin(midle_angle) * distance;
                            x_text += x;
                            y_text = Math.cos(midle_angle) * distance;
                            y_text += y;
                            quadrant = CornerType.BOTTOM_RIGHT;
                        }
                        else if (midle_angle <= Math.PI + Math.PI / 2)
                        {
                            midle_angle = midle_angle - Math.PI;
                            x_text = Math.sin(midle_angle) * distance;
                            x_text = x - x_text;
                            y_text = Math.cos(midle_angle) * distance;
                            y_text += y;
                            quadrant = CornerType.BOTTOM_LEFT;
                        }
                        else
                        {
                            midle_angle = Math.PI * 2 - midle_angle;
                            x_text = Math.sin(midle_angle) * distance;
                            x_text = x - x_text;
                            y_text = Math.cos(midle_angle) * distance;
                            y_text = y - y_text;
                            quadrant = CornerType.TOP_LEFT;
                        }

                        double space = 0;
                        const int SIDE_MARGIN = 5;

                        switch(circle)
                        {
                            case Circle.HOME:
                            case Circle.ROOT:
                                space = get_allocated_width ();
                                space -= x + distance;
                                break;
                            case Circle.BASE:
                                space = get_allocated_width () / 2;
                                space -= radius + (distance-radius);
                                break;
                        }
                        space -= SIDE_MARGIN;
                        x_text += SIDE_MARGIN;
                        draw_text(context, item.get_name(), x_text, y_text, quadrant, space);
                    }
                }
            }
        }

        private void draw_text(Cairo.Context context, string text, double x, double y, CornerType start_corner, double width)
        {
            var layout = create_pango_layout (null);
            var markup = "<span font='10'>" + text + "</span>";
            layout.set_markup (markup, -1);
            layout.set_width ((int) (Pango.SCALE * width));
            layout.set_ellipsize (Pango.EllipsizeMode.END);
            Pango.Rectangle layout_rect;
            layout.get_pixel_extents (null, out layout_rect);

            switch(start_corner)
            {
                case CornerType.TOP_RIGHT:
                    y -= layout_rect.height;
                    break;
                case CornerType.BOTTOM_LEFT:
                    x -= layout_rect.width;
                    break;
                case CornerType.TOP_LEFT:
                    x -= layout_rect.width;
                    y -= layout_rect.height;
                    break;
            }

            get_style_context().render_layout (context, x, y, layout);
        }

        private bool draw_storage_graph(Cairo.Context context)
        {
            int height = this.get_allocated_height ();
            int width = this.get_allocated_width ();

            var storage_list_box = ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box();
            var model = storage_list_box.get_model();

            var two_graphs = false;
            if(storage_list_box.get_root() && StorageAnalyzer.get_default().get_separate_home())
                two_graphs = true;

            double x = 0;
            double y = 0;
            double radius = 0;
            if(two_graphs)
            {
                double border = 5.5;
                radius = int.min (width, height) / 3.5;
                x = width / 1.8;
                x -= x / border;
                y = height / 2.1;
                y -= y / border;
                draw_circle(context, model, x, y, radius, 0, Circle.HOME);

                border = 1.75;
                radius = int.min (width, height) / 11.0;
                x = width / 2.0;
                x += x / border;
                y = height / 1.9;
                y += y / border;
                draw_circle(context, model, x, y, radius, 1, Circle.ROOT);
            }
            else
            {
                radius = int.min (width, height) / 2.0;
                radius -= radius / 3;
                x = width / 2.0;
                y = height / 2.0;

                draw_circle(context, model, x, y, radius, 0, Circle.BASE);
            }

            return true;
        }
    }
}
