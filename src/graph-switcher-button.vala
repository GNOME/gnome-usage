/* graph-switcher-button.vala
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

namespace Usage
{
    public class GraphSwitcherButton : Gtk.ToggleButton
    {
        public GraphSwitcherButton.processor(string label)
        {
            Rg.Graph processor_graph = new CpuGraphMostUsed();
            child = createContent(processor_graph, label);
        }

        public GraphSwitcherButton.memory(string label)
        {
            Rg.Graph memory_graph = new MemoryGraph();
            child = createContent(memory_graph, label);
        }

        public GraphSwitcherButton.network(string label)
        {   //this is kept temporarily for testing NetworkGraph has to be implemented
            Rg.Graph network_graph = new MemoryGraph();
            child = createContent(network_graph, "network");
        }

        private Gtk.Box createContent(Rg.Graph graph, string label_text)
        {
            graph.height_request = 80;
            graph.hexpand = true;
            var graph_box = new GraphBox(graph);
            graph_box.margin_top = 12;
            graph_box.margin_start = 8;
            graph_box.margin_end = 8;

            var label = new Gtk.Label(label_text);
            label.margin_top = 6;
            label.margin_bottom = 3;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(graph_box, true, true, 0);
            box.pack_start(label, false, false, 0);

            return box;
        }

        class construct
        {
            set_css_name("graph-switcher-button");
        }
    }
}
