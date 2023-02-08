/* cpu-sub-view.vala
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

public class Usage.ProcessorSubView : View, SubView {
    private ProcessListBox process_list_box;
    private NoResultsFoundView no_process_view;

    public ProcessorSubView () {
        name = "PROCESSOR";

        var label = new Gtk.Label ("<span font_desc=\"14.0\">" + _("Processor") + "</span>");
        label.set_use_markup (true);
        label.margin_top = 25;
        label.margin_bottom = 15;

        var cpu_graph = new CpuGraph ();
        cpu_graph.hexpand = true;
        var cpu_graph_box = new GraphBox (cpu_graph);
        cpu_graph_box.height_request = 225;
        cpu_graph_box.valign = Gtk.Align.START;

        process_list_box = new ProcessListBox (ProcessListBoxType.PROCESSOR);
        process_list_box.margin_bottom = 20;
        process_list_box.margin_top = 30;

        var spinner = new Gtk.Spinner ();
        spinner.map.connect (spinner.start);
        spinner.unmap.connect (spinner.stop);
        spinner.margin_top = 30;
        spinner.height_request = 250;
        spinner.hexpand = true;
        spinner.halign = Gtk.Align.CENTER;

        no_process_view = new NoResultsFoundView ();

        var cpu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        cpu_box.append (label);
        cpu_box.append (cpu_graph_box);
        cpu_box.append (spinner);
        cpu_box.append (no_process_view);

        var system_monitor = SystemMonitor.get_default ();
        system_monitor.notify["process-list-ready"].connect ((sender, property) => {
            if (system_monitor.process_list_ready) {
                cpu_box.append (process_list_box);
                cpu_box.remove (spinner);
            } else {
                cpu_box.append (spinner);
                cpu_box.remove (process_list_box);
            }
        });

        process_list_box.bind_property ("empty", no_process_view, "visible", BindingFlags.BIDIRECTIONAL);

        set_child (cpu_box);
    }

    public void search_in_processes (string text) {
        process_list_box.search_text = text;
    }
}
