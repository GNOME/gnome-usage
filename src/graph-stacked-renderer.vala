/* graph-stacked-renderer.vala
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

using Dazzle;
using Cairo;

namespace Usage {

    public class GraphStackedRenderer : Object, GraphRenderer {

        public uint column { set; get; }
        public double line_width { set; get; default = 1.0; }
        public Gdk.RGBA stroke_color_rgba { set; get; }
        public Gdk.RGBA stacked_color_rgba { set; get; }

        public void render(GraphModel model, int64 x_begin, int64 x_end, double y_begin, double y_end, Context cr, RectangleInt area) {
            GraphModelIter iter;
            cr.save();

            if (model.get_iter_first(out iter)) {
                double chunk = area.width / (double) (model.max_samples - 1) / 2.0;
                double last_x = calc_x (iter, x_begin, x_end, area.width);
                double last_y = area.height;

                cr.move_to (last_x, area.height);

                while (GraphModel.iter_next (ref iter))
                {
                    double x = calc_x (iter, x_begin, x_end, area.width);
                    double y = calc_y (iter, y_begin, y_end, area.height, column);

                    cr.curve_to (last_x + chunk, last_y, last_x + chunk, y, x, y);

                    last_x = x;
                    last_y = y;
                }
            }

            cr.set_line_width (line_width);
            cr.set_source_rgba (stacked_color_rgba.red, stacked_color_rgba.green, stacked_color_rgba.blue, stacked_color_rgba.alpha);
            cr.rel_line_to (0, area.height);
            cr.stroke_preserve ();
            cr.close_path();
            cr.fill();

            if (model.get_iter_first(out iter)) {
                double chunk = area.width / (double) (model.max_samples - 1) / 2.0;
                double last_x = calc_x (iter, x_begin, x_end, area.width);
                double last_y = area.height;

                cr.move_to (last_x, last_y);

                while (GraphModel.iter_next (ref iter))
                {
                    double x = calc_x (iter, x_begin, x_end, area.width);
                    double y = calc_y (iter, y_begin, y_end, area.height, column);

                    cr.curve_to (last_x + chunk, last_y, last_x + chunk, y, x, y);

                    last_x = x;
                    last_y = y;
                }
            }

            cr.set_source_rgba (stroke_color_rgba.red, stroke_color_rgba.green, stroke_color_rgba.blue, stacked_color_rgba.alpha);
            cr.stroke ();
            cr.restore ();
        }

        private static double calc_x (GraphModelIter iter, int64 begin, int64 end, uint width) {
            var timestamp = GraphModel.iter_get_timestamp(iter);

            return ((timestamp - begin) / (double) (end - begin) * width);
        }

        private static double calc_y (GraphModelIter iter, double range_begin, double range_end, uint height, uint column) {
            double y;

            var val = GraphModel.iter_get_value(iter, column);
            switch (val.type())
            {
                case Type.DOUBLE:
                    y = val.get_double();
                    break;
                case Type.UINT:
                    y = val.get_uint();
                    break;
                case Type.UINT64:
                    y = val.get_uint64();
                    break;
                case Type.INT:
                    y = val.get_int();
                    break;
                case Type.INT64:
                    y = val.get_int64();
                    break;
                default:
                    y = 0.0;
                    break;
            }

            y -= range_begin;
            y /= (range_end - range_begin);
            y = height - (y * height);

            return y;
        }
    }
}
