/* memory-view.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2024 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

[GtkTemplate (ui = "/org/gnome/Usage/ui/memory-view.ui")]
public class Usage.MemoryView : View {
    private ProcessListBox process_list_box;
    private NoResultsFoundView no_process_view;

    [GtkChild]
    private unowned Gtk.Box memory_box;

    public MemoryView () {
        name = "MEMORY";
        title = _("Memory");
        icon_name = "memory-symbolic";
        search_available = true;
        switcher_widget = new GraphBox (new MemoryGraph ());
        switcher_widget.height_request = 80;

        process_list_box = new ProcessListBox (ProcessListBoxType () {
            comparator = (a, b) => {
                return (int) ((uint64) (a.mem_usage < b.mem_usage) - (uint64) (a.mem_usage > b.mem_usage));
            },
            filter = (item) => {
                return item.mem_usage > Settings.get_default ().app_minimum_memory;
            },
            load_widget_factory = (item) => {
                Gtk.Label load_label = new Gtk.Label (Utils.format_size_values (item.mem_usage));

                load_label.ellipsize = Pango.EllipsizeMode.END;
                load_label.max_width_chars = 30;

                return load_label;
            },
        });

        var spinner = new Adw.Spinner () {
            margin_top = 30,
            height_request = 250,
        };

        no_process_view = new NoResultsFoundView ();

        var memory_graph = new MemorySpeedometer ();
        var swap_graph = new SwapSpeedometer ();
        swap_graph.valign = Gtk.Align.END;

        var speedometers = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 12,
            margin_bottom = 6,
        };
        speedometers.append (memory_graph);
        speedometers.append (swap_graph);

        memory_box.append (speedometers);
        memory_box.append (spinner);
        memory_box.append (no_process_view);

        var system_monitor = SystemMonitor.get_default ();
        system_monitor.notify["process-list-ready"].connect ((sender, property) => {
            if (system_monitor.process_list_ready) {
                memory_box.append (process_list_box);
                memory_box.remove (spinner);
            } else {
                memory_box.append (spinner);
                memory_box.remove (process_list_box);
            }
        });

        process_list_box.bind_property ("empty", no_process_view, "visible", BindingFlags.BIDIRECTIONAL);
    }

    public override void set_search_text (string query) {
        process_list_box.search_text = query;
    }
}
