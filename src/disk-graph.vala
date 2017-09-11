/* disk-graph.vala
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

using Rg;

namespace Usage
{
    public class DiskGraph : Rg.Graph
    {
        private const double LINE_WIDTH = 1.2;

        private static DiskGraphTable rg_table;

        class construct
        {
            set_css_name("rg-graph");
        }

        construct
        {
            get_style_context().add_class("line");
            var color_line_read = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");

            get_style_context().add_class("stacked");
            var color_read = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked");

            get_style_context().add_class("line_orange");
            var color_line_write = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_orange");

            get_style_context().add_class("stacked_orange");
            var color_write = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked_orange");

            if(rg_table == null)
            {
                rg_table = new DiskGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            var renderer_read = new StackedRenderer();
            renderer_read.column = DiskGraphTable.COLUMN_READ_ID;
            renderer_read.stroke_color_rgba = color_line_read;
            renderer_read.stacked_color_rgba = color_read;
            renderer_read.line_width = LINE_WIDTH;
            add_renderer(renderer_read);

            var renderer_write = new StackedRenderer();
            renderer_write.column = DiskGraphTable.COLUMN_WRITE_ID;
            renderer_write.stroke_color_rgba = color_line_write;
            renderer_write.stacked_color_rgba = color_write;
            renderer_write.line_width = LINE_WIDTH;
            add_renderer(renderer_write);
        }
    }

    public class DiskGraphBig : Rg.Graph
    {
        private static DiskGraphTable rg_table;
        private const double LINE_WIDTH = 1.5;

        class construct
        {
            set_css_name("rg-graph");
        }

        construct
        {
            get_style_context().add_class("line");
            var color_read = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");

            get_style_context().add_class("line_orange");
            var color_write = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_orange");

            get_style_context().add_class("big");

            if(rg_table == null)
            {
                rg_table = new DiskGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            LineRenderer renderer_read = new LineRenderer();
            renderer_read.column = DiskGraphTable.COLUMN_READ_ID;
            renderer_read.stroke_color_rgba = color_read;
            renderer_read.line_width = LINE_WIDTH;
            add_renderer(renderer_read);

            LineRenderer renderer_write = new LineRenderer();
            renderer_write.column = DiskGraphTable.COLUMN_WRITE_ID;
            renderer_write.stroke_color_rgba = color_write;
            renderer_write.line_width = LINE_WIDTH;
            add_renderer(renderer_write);
        }
    }
}
