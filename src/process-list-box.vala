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
        MEMORY,
        NETWORK
    }

    public class ProcessListBox : Gtk.ListBox
    {
        public bool empty { get; set; default = true; }

        ListStore model;
        ProcessRow? opened_row = null;
        string focused_row_cmdline;
        ProcessListBoxType type;
        string search_text = "";

        public ProcessListBox(ProcessListBoxType type)
        {
            this.type = type;
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
            row_activated.connect((row) => {
                var process_row = (ProcessRow) row;

                if(opened_row != null)
                    opened_row.activate();

                if(opened_row != process_row)
                {
                    process_row.activate();
                    if(process_row.process.sub_processes != null)
                        opened_row = process_row;
                    else
                        opened_row = null;
                }
                else
                    opened_row = null;
            });

            set_focus_child.connect((child) =>
            {
                if(child != null)
                {
                    focused_row_cmdline = ((ProcessRow) child).process.cmdline;
                    //GLib.stdout.printf("focused: " + focused_row_cmdline+ "\n");
                }
            });

            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);

            var settings = Settings.get_default();
            Timeout.add(settings.list_update_interval_UI, update);

            bind_property ("empty", this, "visible", BindingFlags.INVERT_BOOLEAN);
        }

        public bool update()
        {
            CompareDataFunc<Process> processcmp = (a, b) => {
                Process p_a = (Process) a;
                Process p_b = (Process) b;

                switch(type)
                {
                    default:
                    case ProcessListBoxType.PROCESSOR:
                        return (int) ((uint64) (p_a.cpu_load < p_b.cpu_load) - (uint64) (p_a.cpu_load > p_b.cpu_load));
                    case ProcessListBoxType.MEMORY:
                        return (int) ((uint64) (p_a.mem_usage < p_b.mem_usage) - (uint64) (p_a.mem_usage > p_b.mem_usage));
                    //considering only recv bytes , (subject to change) 
                    case ProcessListBoxType.NETWORK:
                        return (int) ((uint64) (p_a.bytes_recv < p_b.bytes_recv) - (uint64) (p_a.bytes_recv > p_b.bytes_recv));
                }
            };

            bind_model(null, null);
            model.remove_all();

            SystemMonitor system_monitor = SystemMonitor.get_default();
            if(search_text == "")
            {
                switch(type)
                {
                    default:
                    case ProcessListBoxType.PROCESSOR:
                        foreach(unowned Process process in system_monitor.get_cpu_processes())
                            model.insert_sorted(process, processcmp);
                        break;
                    case ProcessListBoxType.MEMORY:
                        foreach(unowned Process process in system_monitor.get_ram_processes())
                            model.insert_sorted(process, processcmp);
                        break;
                    case ProcessListBoxType.NETWORK:
                        foreach(unowned Process process in system_monitor.get_network_processes())
                            model.insert_sorted(process, processcmp);
                        break;
                }
            }
            else
            {
                foreach(unowned Process process in system_monitor.get_ram_processes()) //because ram contains all processes
                {
                    if(process.display_name.down().contains(search_text.down()) || process.cmdline.down().contains(search_text.down()))
                        model.insert_sorted(process, processcmp);
                }
            }

            empty = (model.get_n_items() == 0);

            bind_model(model, on_row_created);
            return true;
        }

        public void search(string text)
        {
            search_text = text;
            update();
        }

        private Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            bool opened = false;

            if(opened_row != null)
                if(process.cmdline == opened_row.process.cmdline)
                    opened = true;

            var row = new ProcessRow(process, type, opened);
            if(opened)
               opened_row = row;

            if(focused_row_cmdline != null)
            {
                if(process.cmdline == focused_row_cmdline)
                {
                    //row.grab_focus(); TODO not working
                    //GLib.stdout.printf("grab focus for: " + focused_row_cmdline+ "\n");
                }
            }

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
