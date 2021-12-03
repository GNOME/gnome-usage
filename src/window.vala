/* window.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2020 Adrien Plazas <kekun.plazas@laposte.net>
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

namespace Usage {
    public enum Views {
        PERFORMANCE,
        STORAGE,
    }

    public enum HeaderBarMode {
        PERFORMANCE,
        STORAGE,
    }

    [GtkTemplate (ui = "/org/gnome/Usage/ui/window.ui")]
    public class Window : Hdy.ApplicationWindow {
        [GtkChild]
        private unowned Gtk.Stack stack;

        [GtkChild]
        private unowned Gtk.Revealer performance_search_revealer;

        [GtkChild]
        private unowned Gtk.ToggleButton performance_search_button;

        [GtkChild]
        private unowned Gtk.MenuButton primary_menu_button;

        private HeaderBarMode mode;
        private Usage.PrimaryMenu menu;

        private View[] views;

        public Window(Gtk.Application application) {
            GLib.Object(application : application);

            if (Config.PROFILE == "Devel") {
                get_style_context().add_class("devel");
            }

            load_css();
            Gtk.Settings.get_for_screen(get_screen()).notify["gtk-application-prefer-dark-theme"].connect(() => {
                load_css();
            });

            mode = HeaderBarMode.PERFORMANCE;
            menu = new Usage.PrimaryMenu();
            this.primary_menu_button.set_popover(menu);

            set_mode(HeaderBarMode.PERFORMANCE);

            views = new View[] {
                new PerformanceView(),
                new StorageView(),
            };

            foreach (var view in views) {
                stack.add_titled(view, view.name, view.title);
                stack.child_set (view, "icon-name", view.icon_name, null);
            }
        }

        public void set_mode(HeaderBarMode mode) {
            switch (this.mode) {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_revealer.reveal_child = false;
                    break;
                case HeaderBarMode.STORAGE:
                    break;
            }

            switch (mode) {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_revealer.reveal_child = true;
                    break;
                case HeaderBarMode.STORAGE:
                    break;
            }
            menu.mode = mode;
            this.mode = mode;
        }

        public void action_on_search() {
            switch (mode) {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_button.set_active(!performance_search_button.get_active());
                    break;
                case HeaderBarMode.STORAGE:
                    break;
            }
        }

        public View[] get_views() {
            return views;
        }

        private void load_css() {
            var provider = new Gtk.CssProvider();
            Gtk.StyleContext.reset_widgets(get_screen());
            provider.load_from_resource("/org/gnome/Usage/interface/adwaita.css");
            Gtk.StyleContext.add_provider_for_screen(get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        [GtkCallback]
        private void on_performance_search_button_toggled () {
            /* TODO: Implement a saner way of toggling this mode. */
            ((PerformanceView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.PERFORMANCE]).set_search_mode(performance_search_button.active);
        }

        [GtkCallback]
        private void on_visible_child_changed() {
            if (stack.visible_child_name == views[Views.PERFORMANCE].name) {
                set_mode(HeaderBarMode.PERFORMANCE);
            } else if (stack.visible_child_name == views[Views.STORAGE].name) {
                set_mode(HeaderBarMode.STORAGE);
            }
        }
    }
}
