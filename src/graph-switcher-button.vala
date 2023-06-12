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

public class Usage.GraphSwitcherButton : Gtk.ToggleButton {
    private static Gtk.ToggleButton? _group = null;

    public GraphSwitcherButton.processor (string label) {
        var processor_graph = new CpuGraphMostUsedCore ();
        child = createContent (processor_graph, label);
    }

    public GraphSwitcherButton.memory (string label) {
        var memory_graph = new MemoryGraph ();
        child = createContent (memory_graph, label);
    }

    private Gtk.Box createContent (GraphView graph, string label_text) {
        graph.height_request = 80;
        graph.hexpand = true;
        var graph_box = new GraphBox (graph);
        graph_box.margin_top = 12;
        graph_box.margin_start = 8;
        graph_box.margin_end = 8;

        var label = new Gtk.Label (label_text);
        label.margin_top = 6;
        label.margin_bottom = 3;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (graph_box);
        box.append (label);

        return box;
    }

    construct {
        if (_group == null)
            _group = this;
        else
            set_group (_group);

        this.add_css_class ("flat");
        this.add_css_class ("graph-switcher");
    }
}
