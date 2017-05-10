/* memory-graph.vala
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

using Rg;

namespace Usage
{
    public class MemoryGraph : Rg.Graph
    {
		private static MemoryGraphTable rg_table;
		private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public MemoryGraph ()
        {
            get_style_context().add_class("line_max");
            line_color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_max");
            get_style_context().add_class("line");
            line_color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("stacked_max");
            color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked_max");
            get_style_context().add_class("stacked");
            color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked");

            if(rg_table == null)
            {
                rg_table = new MemoryGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            var renderer_ram = new StackedRenderer();
            renderer_ram.column = MemoryGraphTable.column_ram_id;
            renderer_ram.stroke_color_rgba = line_color_normal;
            renderer_ram.stacked_color_rgba = color_normal;
            renderer_ram.line_width = 1.2;
            add_renderer(renderer_ram);

            rg_table.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_max;
                renderer_ram.stacked_color_rgba = color_max;
            });

            rg_table.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });
        }
    }

    public class MemoryGraphBig : Rg.Graph
    {
		private static MemoryGraphTable rg_table;
		private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public MemoryGraphBig()
        {
            get_style_context().add_class("line_max");
            line_color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_max");
            get_style_context().add_class("line");
            line_color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("stacked_max");
            color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked_max");
            get_style_context().add_class("stacked");
            color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked");
            get_style_context().add_class("big");

            if(rg_table == null)
            {
                rg_table = new MemoryGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            var renderer_ram = new StackedRenderer();
            renderer_ram.column = MemoryGraphTable.column_ram_id;
            renderer_ram.stroke_color_rgba = line_color_normal;
            renderer_ram.stacked_color_rgba = color_normal;
            renderer_ram.line_width = 1.5;
            add_renderer(renderer_ram);

            rg_table.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });

            rg_table.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });
        }
    }
}
