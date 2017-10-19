/* header-bar.vala
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

using Gtk;

namespace Usage
{
    public enum HeaderBarMode
    {
        PERFORMANCE,
        STORAGE
    }

    [GtkTemplate (ui = "/org/gnome/Usage/ui/header-bar.ui")]
    public class HeaderBar : Gtk.HeaderBar
    {
        [GtkChild]
        private Gtk.StackSwitcher stack_switcher;

        [GtkChild]
        private Gtk.ToggleButton performance_search_button;

        [GtkChild]
        private Gtk.Button storage_back_button;

        [GtkChild]
        private Gtk.Button storage_rescan_button;

        [GtkChild]
        private Gtk.Button storage_select_button;

        [GtkChild]
        private Gtk.Button storage_cancel_button;

	    private Gtk.MenuButton? storage_selection_menu;
	    private string title_text = "";
	    private HeaderBarMode mode;

	    const GLib.ActionEntry[] select_action_entries = {
           { "select-all", select_all },
           { "select-none", select_none },
        };

	    public HeaderBar(Gtk.Stack stack)
	    {
	        mode = HeaderBarMode.PERFORMANCE;
            stack_switcher.set_stack(stack);

            set_mode(HeaderBarMode.PERFORMANCE);
	    }

	    public void set_mode(HeaderBarMode mode)
	    {
            switch(this.mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_button.hide ();
                    break;
                case HeaderBarMode.STORAGE:
                    storage_back_button.hide ();
                    storage_rescan_button.hide ();
                    storage_select_button.hide ();
                    storage_cancel_button.hide ();
                    break;
            }

            switch(mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    show_stack_switcher();

                    performance_search_button.show();
                    break;
                case HeaderBarMode.STORAGE:
                    if(title_text == "")
                        show_stack_switcher();
                    else
                        show_title();

                    storage_rescan_button.show ();
                    storage_select_button.show ();

                    break;
            }
            this.mode = mode;
	    }

        [GtkCallback]
        private void on_performance_search_button_toggled () {
            /* TODO: Implement a saner way of toggling this mode. */
            ((PerformanceView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.PERFORMANCE]).set_search_mode(performance_search_button.active);
        }

        [GtkCallback]
        private void on_storage_back_button_clicked () {
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().on_back_button_clicked();
        }

        [GtkCallback]
        private void on_storage_rescan_button_clicked () {
            stack_switcher.show ();

            storage_select_button.hide ();
            storage_rescan_button.hide ();

            storage_back_button.hide ();
            StorageAnalyzer.get_default().create_cache.begin(true);
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().reload();
        }

        [GtkCallback]
        private void on_storage_cancel_button_clicked () {
            show_storage_selection_mode(false);
        }

        [GtkCallback]
        private void on_storage_select_button_clicked () {
            show_storage_selection_mode(true);
        }

	    public void change_selected_items(uint count)
	    {
	        if(storage_selection_menu != null)
	        {
	            if(count > 0)
                    storage_selection_menu.label = ngettext ("%u selected", "%u selected", count).printf (count);
                else
                    storage_selection_menu.label = _("Click on items to select them");
	        }
	    }

	    public HeaderBarMode get_mode()
	    {
	        return mode;
	    }

	    public void show_title()
	    {
	        set_custom_title(null);
            set_title(title_text);
	    }

	    public void set_title_text(string title)
        {
            this.title_text = title;
        }

	    public void show_stack_switcher()
        {
            set_custom_title(stack_switcher);
        }

        public void show_storage_back_button(bool show)
        {
            storage_back_button.visible = show;
        }

        public void show_storage_rescan_button(bool show)
        {
            storage_rescan_button.visible = show;
        }

        public void show_storage_select_button(bool show)
        {
            storage_select_button.visible = show;
        }

        public void action_on_search()
        {
            switch(mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_button.set_active(!performance_search_button.get_active());
                    break;
                case HeaderBarMode.STORAGE:
                    break;
            }
        }

        public void show_storage_selection_mode(bool show)
        {
            if(show)
            {
                storage_rescan_button.hide ();
                storage_select_button.hide ();
                storage_back_button.hide();
                storage_cancel_button.show();
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).show_action_bar(true);
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().set_select_mode(true);

                var menu = new GLib.Menu ();
                var item = new GLib.MenuItem (_("Select all"), "headerbar.select-all");
                item.set_attribute("accel", "s", "<Primary>a");
                menu.append_item(item);

                item = new GLib.MenuItem (_("Select None"), "headerbar.select-none");
                menu.append_item(item);

                storage_selection_menu = new Gtk.MenuButton();
                storage_selection_menu.get_style_context().add_class("selection-menu");
                storage_selection_menu.set_menu_model(menu);

                var action_group = new GLib.SimpleActionGroup ();
                action_group.add_action_entries (select_action_entries, this);
                storage_selection_menu.get_popover().insert_action_group ("headerbar", action_group);

                storage_selection_menu.show();
                set_custom_title(storage_selection_menu);
                change_selected_items(0);

                this.get_style_context().add_class("selection-mode");
                this.show_close_button = false;
            }
            else
            {
                storage_back_button.show ();

                storage_rescan_button.show ();
                storage_select_button.show ();
                storage_cancel_button.hide();
                storage_selection_menu = null;
                if(title_text == "")
                    show_stack_switcher();
                else
                    show_title();
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).show_action_bar(false);
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().set_select_mode(false);
                this.get_style_context().remove_class("selection-mode");
                this.show_close_button = true;
            }
        }

        private void select_all()
        {
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().select_all_rows();

        }

        private void select_none()
        {
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().unselect_all_rows();
        }
    }
}
