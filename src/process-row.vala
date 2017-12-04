/* process-row.vala
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
    [GtkTemplate (ui = "/org/gnome/Usage/ui/process-row.ui")]
    public class ProcessRow : Gtk.ListBoxRow
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
        public bool group {
            get {
                return process.sub_processes != null;
            }
        }

        private const int MAX_CPU_USAGE_LIMIT = 90;
        private const int MAX_MEMORY_USAGE_LIMIT = 90;

        public ProcessRow(Process process, ProcessListBoxType type, bool opened = false)
        {
            this.type = type;
            this.process = process;

            load_icon(process.display_name);
            update();
        }

        private void load_icon(string display_name)
        {
            var app_info = SystemMonitor.get_default().get_app_info(display_name);
            var app_icon = (app_info == null) ? null : app_info.get_icon();

            if (app_info == null || app_icon == null)
                icon.gicon = new GLib.ThemedIcon("system-run-symbolic");
            else
                icon.gicon = app_icon;
        }

        private void update()
        {
            update_load_label();
            check_max_usage();
            set_styles();

            if(group)
                title_label.label = process.display_name + " (" + process.sub_processes.size().to_string() + ")";
            else
                title_label.label = process.display_name;
        }

        private void update_load_label()
        {
            CompareFunc<uint64?> sort = (a, b) => {
                return (int) ((uint64) (a < b) - (uint64) (a > b));
            };

            switch(type)
            {
                case ProcessListBoxType.PROCESSOR:
                    load_label.label = ((int) process.cpu_load).to_string() + " %";
                    break;
                case ProcessListBoxType.MEMORY:
                    load_label.label = Utils.format_size_values(process.mem_usage);
                    break;
            }
        }

        private void check_max_usage()
        {
            switch(type)
            {
                case ProcessListBoxType.PROCESSOR:
                    if(process.cpu_load >= MAX_CPU_USAGE_LIMIT)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;

                case ProcessListBoxType.MEMORY:
                    SystemMonitor monitor = SystemMonitor.get_default();

                    if((((double) process.mem_usage / monitor.ram_total) * 100) >= MAX_MEMORY_USAGE_LIMIT)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
            }
        }

        public new void activate()
        {
            var settings = Settings.get_default();
            if (process.cmdline in settings.get_strv ("unkillable-processes"))
                return;

            var dialog = new QuitProcessDialog(process);
            dialog.set_transient_for(get_toplevel() as Gtk.Window);
            dialog.show_all();
        }

        private void set_styles()
        {
            if(max_usage)
                get_style_context().add_class("max");
            else
                get_style_context().remove_class("max");
        }
    }
}
