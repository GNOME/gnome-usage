/* cpu-view.vala
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

[GtkTemplate (ui = "/org/gnome/Usage/ui/cpu-view.ui")]
public class Usage.CpuView : View {
    private ProcessListBox process_list_box;
    private NoResultsFoundView no_process_view;

    [GtkChild]
    private unowned Gtk.Box cpu_box;

    public CpuView () {
        name = "PROCESSOR";
        title = _("Processor");
        icon_name = "speedometer-symbolic";
        search_available = true;
        switcher_widget = new GraphBox (new CpuGraphMostUsedCore ());
        switcher_widget.height_request = 80;

        var cpu_graph = new CpuGraph ();
        var cpu_graph_box = new GraphBox (cpu_graph);
        cpu_graph_box.height_request = 225;
        cpu_graph_box.valign = Gtk.Align.START;
        cpu_graph_box.add_css_class ("card");

        process_list_box = new ProcessListBox (ProcessListBoxType () {
            comparator = (a, b) => {
                return (int) ((uint64) (a.cpu_load < b.cpu_load) - (uint64) (a.cpu_load > b.cpu_load));
            },
            filter = (item) => {
                return item.cpu_load > Settings.get_default ().app_minimum_load;
            },
            load_widget_factory = (item) => {
                Gtk.Label load_label = new Gtk.Label ("%.1f %%".printf (item.cpu_load * 100));

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
    }

    public override void set_search_text (string query) {
        process_list_box.search_text = query;
    }
}
