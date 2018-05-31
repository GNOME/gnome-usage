/* process-list-box.vala
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
    public enum ProcessListBoxType {
        PROCESSOR,
        MEMORY
    }

    public class ProcessListBox : Gtk.ListBox
    {
        public bool empty { get; set; default = true; }
        public string search_text { get; set; default = ""; }

        private const double APP_CPU_MIN_LOAD_LIMIT = 1;
        private const double APP_MEM_MIN_USAGE_LIMIT = 0;
        private ListStore model;
        private ProcessListBoxType type;

        public ProcessListBox(ProcessListBoxType type)
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);

            this.type = type;
            model = new ListStore(typeof(AppItem));
            bind_model(model, on_row_created);

            row_activated.connect((row) => {
                var process_row = (ProcessRow) row;
                process_row.activate();
            });

            this.notify["search-text"].connect ((sender, property) => {
                update();
            });

            var system_monitor = SystemMonitor.get_default();
            system_monitor.notify["process-list-ready"].connect (() => {
                if(system_monitor.process_list_ready)
                    update();
            });

            var settings = Settings.get_default();
            Timeout.add(settings.list_update_interval_UI, update);

            bind_property ("empty", this, "visible", BindingFlags.INVERT_BOOLEAN);
        }

        private bool update()
        {
            model.remove_all();

            CompareDataFunc<AppItem> app_cmp = (a, b) => {
                AppItem app_a = (AppItem) a;
                AppItem app_b = (AppItem) b;

                switch(type) {
                    default:
                    case ProcessListBoxType.PROCESSOR:
                        return (int) ((uint64) (app_a.cpu_load < app_b.cpu_load) - (uint64) (app_a.cpu_load > app_b.cpu_load));
                    case ProcessListBoxType.MEMORY:
                        return (int) ((uint64) (app_a.mem_usage < app_b.mem_usage) - (uint64) (app_a.mem_usage > app_b.mem_usage));
                }
            };

            var system_monitor = SystemMonitor.get_default();
            if(search_text == "") {
                switch(type)
                {
                    default:
                    case ProcessListBoxType.PROCESSOR:
                        foreach(unowned AppItem app in system_monitor.get_apps()) {
                            if(app.cpu_load > APP_CPU_MIN_LOAD_LIMIT)
                                model.insert_sorted(app, app_cmp);
                        }
                        break;
                    case ProcessListBoxType.MEMORY:
                        foreach(unowned AppItem app in system_monitor.get_apps())
                            if(app.mem_usage > APP_MEM_MIN_USAGE_LIMIT)
                                model.insert_sorted(app, app_cmp);
                        break;
                }
            }
            else {
                foreach(unowned AppItem app in system_monitor.get_apps()) {
                    if(app.display_name.down().contains(search_text.down()) || app.representative_cmdline.down().contains(search_text.down()))
                        model.insert_sorted(app, app_cmp);
                }
            }

            empty = (model.get_n_items() == 0);
            return true;
        }

        private Gtk.Widget on_row_created (Object item) {
            return new ProcessRow((AppItem) item, type);
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row) {
            if(before_row == null)
                row.set_header(null);
            else {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
                separator.get_style_context().add_class("list");
                separator.show();
                row.set_header(separator);
            }
        }
    }
}
