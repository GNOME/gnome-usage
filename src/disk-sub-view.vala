/* disk-sub-view.vala
 *
 * Copyright (C) 2019 Red Hat, Inc.
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
    [GtkTemplate (ui = "/org/gnome/Usage/ui/disk-sub-view.ui")]
    public class DiskSubView : View, SubView {
        [GtkChild]
        private Gtk.Spinner spinner;

        [GtkChild]
        private NoResultsFoundView no_process_view;

        [GtkChild]
        private Usage.ProcessListBox process_list_box;

        construct {
            process_list_box.type = ProcessListBoxType.DISK;

            var system_monitor = SystemMonitor.get_default();

           system_monitor.notify["disk-process-list-ready"].connect ((sender, property) => {
                if(system_monitor.disk_process_list_ready) {
                    spinner.active = false;
                    spinner.visible = false;
                }
            });

            process_list_box.bind_property ("visible", no_process_view, "visible", BindingFlags.INVERT_BOOLEAN);
        }

        public void search_in_processes(string text) {
            process_list_box.search_text = text;
        }
    }
}
