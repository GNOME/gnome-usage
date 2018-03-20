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
        private Gtk.Box user_tag_box;

        [GtkChild]
        private Gtk.Label user_tag_label;

        [GtkChild]
        private Gtk.Box process_details_box;

        [GtkChild]
        private Gtk.Label load_label;

        [GtkChild]
        private Gtk.Label load_label_net_incoming;

        [GtkChild]
        private Gtk.Image icon_transmit;

        [GtkChild]
        private Gtk.Image icon_receive;

        private Act.User user;

        public Process process { get; private set; }
        public bool max_usage { get; private set; }
        public bool group {
            get {
                return process.sub_processes != null;
            }
        }

        private const int MAX_CPU_USAGE_LIMIT = 90;
        private const int MAX_MEMORY_USAGE_LIMIT = 90;

        private const string CSS_TAG_USER = "tag-user";
        private const string CSS_TAG_ROOT = "tag-root";
        private const string CSS_TAG_SYSTEM = "tag-system";

        public ProcessRow(Process process, ProcessListBoxType type, bool opened = false)
        {
            this.type = type;
            this.process = process;
            this.user = Act.UserManager.get_default().get_user_by_id(process.uid);

            load_icon(process.display_name);
            update();

            this.user.notify["is-loaded"].connect(() => {
                update_user_tag();
            });
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
            update_user_tag();
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
                case ProcessListBoxType.NETWORK:
                    load_label.label = "%.2f".printf(process.net_stats.bytes_sent) + " kbps";
                    load_label_net_incoming.label = "%.2f".printf(process.net_stats.bytes_recv) + " kbps";
                    load_label_net_incoming.visible= true;
                    icon_receive.visible = true;
                    icon_transmit.visible = true;
                    break;
            }
        }

        private void update_user_tag()
        {
            remove_user_tag();
            if(user.is_loaded)
            {
                create_user_tag();
            }
        }

        private void remove_user_tag()
        {
            user_tag_box.visible = false;
            user_tag_box.get_style_context().remove_class(CSS_TAG_USER);
            user_tag_box.get_style_context().remove_class(CSS_TAG_ROOT);
            user_tag_box.get_style_context().remove_class(CSS_TAG_SYSTEM);
        }

        private void create_user_tag()
        {
            user_tag_box.visible = true;

            var tag_label = user.real_name.split(" ");
            if (user.real_name.contains("User for") ||
                user.real_name.contains("Default user for"))
                user_tag_label.label = tag_label[tag_label.length - 1];
            else
                user_tag_label.label = user.real_name;

            string class_name = "";
            if(is_regular_user())
            {
                class_name = CSS_TAG_USER;
            }
            else if(is_root_user())
            {
                class_name = CSS_TAG_ROOT;
            }
            else if(is_system_user())
            {
                class_name = CSS_TAG_SYSTEM;
            }
            user_tag_box.get_style_context().add_class(class_name);

            if(is_logged_in())
            {
                user_tag_box.visible = false;
            }
        }

        private bool is_regular_user(){
            return user.is_local_account();
        }

        private bool is_root_user(){
            return user.uid == 0;
        }

        private bool is_system_user(){
            return !is_regular_user() && !is_root_user();
        }

        private bool is_logged_in(){
            return user.user_name == GLib.Environment.get_user_name();
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
