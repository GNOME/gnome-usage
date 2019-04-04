/* memory-sub-view.vala
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
    public class MemorySubView : View, SubView
    {
        private ProcessListBox process_list_box;
        private NoResultsFoundView no_process_view;

        public MemorySubView()
        {
            name = "MEMORY";

            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Memory") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 25;
            label.margin_bottom = 15;

            process_list_box = new ProcessListBox();
            process_list_box.type = ProcessListBoxType.MEMORY;
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            no_process_view = new NoResultsFoundView();

            var memory_graph = new MemorySpeedometer();
            var swap_graph = new SwapSpeedometer();
            swap_graph.valign = Gtk.Align.END;

            var speedometers = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            speedometers.pack_start(memory_graph, false, false, 0);
            speedometers.pack_end(swap_graph, false, false, 0);
            speedometers.margin_top = 30;

            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            memory_box.halign = Gtk.Align.CENTER;
            memory_box.pack_start(label, false, false, 0);
            memory_box.pack_start(speedometers, false, false, 0);
            memory_box.pack_start(process_list_box, false, false, 0);
            memory_box.add(no_process_view);

            process_list_box.bind_property ("empty", no_process_view, "visible", BindingFlags.BIDIRECTIONAL);
            add(memory_box);
            show_all();
        }

        public override void show_all() {
            base.show_all();
            this.no_process_view.hide();
        }

        public void search_in_processes(string text)
        {
            process_list_box.search_text = text;
        }
    }
}
