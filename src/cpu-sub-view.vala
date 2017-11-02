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

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/cpu-sub-view.ui")]
    public class ProcessorSubView : View, SubView
    {
        [GtkChild]
        private BetterBox better_box;

        [GtkChild]
        private Gtk.Box cpu_box;

        [GtkChild]
        private Gtk.Box graph_placeholder;

        [GtkChild]
        private Gtk.Box process_list_placeholder;

        [GtkChild]
        private Gtk.Spinner spinner;

        [GtkChild]
        private NoResultsFoundView no_process_view;

        private ProcessListBox process_list_box;

        public ProcessorSubView()
        {
            //TODO: Remove graph_placeholder; migrate to gtk+3 templates
            var cpu_graph = new CpuGraphBig();
            cpu_graph.hexpand = true;
            var cpu_graph_box = new GraphBox(cpu_graph);
            cpu_graph_box.height_request = 225;
            cpu_graph_box.width_request = 600;
            cpu_graph_box.valign = Gtk.Align.START;
            graph_placeholder.add(cpu_graph_box);

            //TODO: Remove process_list_placeholder; migrate to gtk+3 templates
            process_list_box = new ProcessListBox(ProcessListBoxType.PROCESSOR);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            SystemMonitor.get_default().cpu_processes_ready.connect(() =>
            {
                process_list_placeholder.pack_start(process_list_box, false, false, 0);
                process_list_box.update();
                cpu_box.remove(spinner);
            });

            process_list_box.bind_property ("empty", no_process_view, "visible", BindingFlags.BIDIRECTIONAL);
        }

        public override void show_all() {
            base.show_all();
            this.no_process_view.hide();
        }

        public void search_in_processes(string text)
        {
            process_list_box.search(text);
        }
    }
}
