/* sub-process-sub-row.vala
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
    [GtkTemplate (ui = "/org/gnome/Usage/ui/sub-process-sub-row.ui")]
    public class SubProcessSubRow : Gtk.ListBoxRow
    {
        ProcessListBoxType type;

        [GtkChild]
        private Gtk.Image icon;

        [GtkChild]
        private Gtk.Label title_label;

        [GtkChild]
        private Gtk.Label load_label;

        public Process process { get; private set; }
        public bool max_usage { get; private set; }

        private const int MAX_CPU_USAGE_LIMIT = 90;
        private const int MAX_MEMORY_USAGE_LIMIT = 90;

        public SubProcessSubRow(Process process, ProcessListBoxType type)
        {
            this.type = type;
            this.process = process;

            icon.set_from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);
            title_label.label = process.display_name;

            notify["max-usage"].connect (() => {
                set_styles();
            });
            update();
        }

        private void update()
        {
            update_load_label();
        }

        private void update_load_label()
        {
            switch(type)
            {
                case ProcessListBoxType.PROCESSOR:
                    load_label.label = ((uint64) process.cpu_load).to_string() + " %";

                    if(process.cpu_load >= MAX_CPU_USAGE_LIMIT)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
                case ProcessListBoxType.MEMORY:
                    SystemMonitor monitor = SystemMonitor.get_default();
                    load_label.label = Utils.format_size_values(process.mem_usage);

                    if((((double) process.mem_usage / monitor.ram_total) * 100) >= MAX_MEMORY_USAGE_LIMIT)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
            }
        }

        private void set_styles()
        {
            if(max_usage == true)
                get_style_context().add_class("max");
            else
                get_style_context().remove_class("max");
        }

        public new void activate()
        {
            var dialog = new QuitProcessDialog(process.pid, process.cmdline);
            dialog.show_all();
        }
    }
}
