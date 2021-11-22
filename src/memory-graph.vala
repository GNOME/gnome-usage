/* memory-graph.vala
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

namespace Usage {
    public class MemoryGraph : GraphView {
        private static MemoryGraphModel graph_model;
        private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct {
            set_css_name("rg-graph");
        }

        public MemoryGraph () {
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

            if (graph_model == null) {
                graph_model = new MemoryGraphModel();
                set_model(graph_model);
            } else {
                set_model(graph_model);
            }

            var renderer_ram = new GraphStackedRenderer();
            renderer_ram.column = MemoryGraphModel.COLUMN_RAM;
            renderer_ram.stroke_color_rgba = line_color_normal;
            renderer_ram.stacked_color_rgba = color_normal;
            renderer_ram.line_width = 1.2;
            add_renderer(renderer_ram);

            graph_model.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_max;
                renderer_ram.stacked_color_rgba = color_max;
            });

            graph_model.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });
        }
    }
}
