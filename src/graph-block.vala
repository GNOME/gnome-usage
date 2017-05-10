/* graph-block.vala
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
    public enum GraphBlockType {
        PROCESSOR,
        MEMORY,
        DISK,
        NETWORK
    }

    public class GraphBlock : Gtk.Grid
    {
        PieChart graph;
        GraphBlockRow application_row;
        GraphBlockRow others_row;
        GraphBlockRow available_row;
        Gtk.Label label;
        string block_name;
        bool show_avaiable;
        GraphBlockType type;

        class construct
        {
            set_css_name("GraphBlock");
        }

        public GraphBlock(GraphBlockType type, string block_name, string app_name, bool show_avaiable = true)
        {
            this.type = type;
            this.expand = true;
            this.block_name = block_name;
            this.show_avaiable = show_avaiable;
            label = new Gtk.Label("<span font_desc=\"11.0\"><b>" + block_name + "</b></span>");
            label.set_use_markup(true);
            this.attach(label, 0, 0, 1, 1);

            graph = new PieChart();
            graph.margin = 15;
            graph.height_request = 90;
            graph.width_request = 90;
            this.attach(graph, 0, 1, 1, 1);

            application_row = new GraphBlockRow(type, app_name, "used");
            others_row = new GraphBlockRow(type, _("Others"), "others");
            if(show_avaiable)
                available_row = new GraphBlockRow(type, _("Available"), "available");

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin_left = 15;
            box.valign = Align.CENTER;
            box.pack_start(application_row, false, false);
            box.pack_start(others_row , false, false);
            if(show_avaiable)
                box.pack_start(available_row, false, false);
            this.attach(box, 1, 1, 1, 1);
        }

        public void update(uint64 application, uint64 other, uint64 all, int processor_core = -1)
        {
            if(processor_core != -1)
            {
                label.set_text("<span font_desc=\"11.0\"><b>" + block_name + " " + processor_core.to_string() + "</b></span>");
                label.use_markup = true;
            }
            else
            {
                label.set_text("<span font_desc=\"11.0\"><b>" + block_name + "</b></span>");
                label.use_markup = true;
            }

            int application_percentages = 0;
            if(all != 0)
                application_percentages = (int) (((double) application / all) * 100);

            int other_percentages = 0;
            if(all != 0)
                other_percentages = (int) (((double) other / all) * 100);

            graph.update(application_percentages, other_percentages);
            application_row.update(application);
            others_row.update(other);
            if(show_avaiable)
                available_row.update(all-other-application);
        }
    }
}
