/* sub-process-list-box.vala
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
    [GtkTemplate (ui = "/org/gnome/Usage/ui/sub-process-list-box.ui")]
    public class SubProcessListBox : Gtk.ListBox
    {
        ListStore model;
        Process parent_process;
        ProcessListBoxType type;

        class construct
        {
            set_css_name("subprocess-list");
        }

        construct
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);

            row_activated.connect( (row) => {
                var sub_process_row = (SubProcessSubRow) row;
                sub_process_row.activate();
            });
        }

        public void init(Process process, ProcessListBoxType type)
        {
            this.type = type;
            parent_process = process;

            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);
            update();
        }

        private void update()
        {
            CompareDataFunc<Process> processcmp = (a, b) => {
                Process p_a = (Process) a;
                Process p_b = (Process) b;

                switch(type)
                {
                    default:
                    case ProcessListBoxType.PROCESSOR:
                        return (int) ((uint64) (p_a.get_cpu_load() < p_b.get_cpu_load()) - (uint64) (p_a.get_cpu_load() > p_b.get_cpu_load()));
                    case ProcessListBoxType.MEMORY:
                        return (int) ((uint64) (p_a.get_mem_usage() < p_b.get_mem_usage()) - (uint64) (p_a.get_mem_usage() > p_b.get_mem_usage()));
                }
            };

           if(parent_process.get_sub_processes() != null)
           {
               foreach(unowned Process process in parent_process.get_sub_processes().get_values())
               {
                   model.insert_sorted(process, processcmp);
               }
           }
        }

        private Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            var row = new SubProcessSubRow(process, type);
            return row;
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
        {
            if(before_row == null)
                row.set_header(null);
            else
            {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
                separator.get_style_context().add_class("list");
                separator.show();
                row.set_header(separator);
            }
        }
    }
}
