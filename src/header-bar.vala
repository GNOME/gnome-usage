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
        STORAGE,
    }

    [GtkTemplate (ui = "/org/gnome/Usage/ui/header-bar.ui")]
    public class HeaderBar : Hdy.HeaderBar
    {
        [GtkChild]
        private Hdy.Squeezer squeezer;

        [GtkChild]
        private Hdy.ViewSwitcher view_switcher;

        [GtkChild]
        private Gtk.Label title_label;

        [GtkChild]
        private Gtk.Revealer performance_search_revealer;

        [GtkChild]
        private Gtk.ToggleButton performance_search_button;

        [GtkChild]
        private Gtk.MenuButton primary_menu_button;

	    private string title_text = "";
	    private HeaderBarMode mode;
	    private Usage.PrimaryMenu menu;

	    public bool view_switcher_visible { get; private set; }

	    public HeaderBar(Gtk.Stack stack)
	    {
	        mode = HeaderBarMode.PERFORMANCE;
	        menu = new Usage.PrimaryMenu();
            view_switcher.set_stack(stack);
            this.primary_menu_button.set_popover(menu);

            set_mode(HeaderBarMode.PERFORMANCE);
	    }

        construct {
            update_view_switcher_visible ();
        }

	    public void set_mode(HeaderBarMode mode)
	    {
            switch(this.mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_revealer.reveal_child = false;
                    break;
                case HeaderBarMode.STORAGE:
                    break;
            }

            switch(mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    show_view_switcher();
                    performance_search_revealer.reveal_child = true;
                    break;
                case HeaderBarMode.STORAGE:
                    show_view_switcher();
                    break;
            }
            menu.mode = mode;
            this.mode = mode;
	    }

        private void update_view_switcher_visible () {
            view_switcher_visible = squeezer.visible_child == view_switcher;
        }

        [GtkCallback]
        private void on_squeezer_visible_child_changed () {
            update_view_switcher_visible ();
        }

        [GtkCallback]
        private void on_performance_search_button_toggled () {
            /* TODO: Implement a saner way of toggling this mode. */
            ((PerformanceView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.PERFORMANCE]).set_search_mode(performance_search_button.active);
        }

	    public HeaderBarMode get_mode()
	    {
	        return mode;
	    }

	    public void show_title()
	    {
            squeezer.set_child_enabled(view_switcher, false);
            set_title(title_text);
	    }

	    public void set_title_text(string title)
        {
            this.title_text = title;
            title_label.label = title;
        }

	    public void show_view_switcher()
        {
            squeezer.set_child_enabled(view_switcher, true);
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
    }
}
