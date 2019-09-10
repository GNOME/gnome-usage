/* window.vala
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
    public enum Views
    {
        PERFORMANCE,
        STORAGE,
    }

    public class Window : Gtk.ApplicationWindow
    {
        private Usage.HeaderBar header_bar;
        private Hdy.ViewSwitcherBar viewswitcher_bar;
        private View[] views;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);

            this.set_default_size(950, 600);
            this.window_position = Gtk.WindowPosition.CENTER;
            this.set_title(_("Usage"));

            if(Config.PROFILE == "Devel") {
                get_style_context().add_class("devel");
            }

            load_css();
            Gtk.Settings.get_for_screen(get_screen()).notify["gtk-application-prefer-dark-theme"].connect(() =>
            {
                load_css();
            });

			var stack = new Gtk.Stack();
            stack.set_size_request(360, 200);
            stack.visible = true;
            stack.vexpand = true;
			header_bar = new Usage.HeaderBar(stack);
			set_titlebar(header_bar);
            viewswitcher_bar = new Hdy.ViewSwitcherBar();
            viewswitcher_bar.visible = true;
            viewswitcher_bar.stack = stack;
            header_bar.bind_property ("title-visible", viewswitcher_bar, "reveal", BindingFlags.SYNC_CREATE);

            views = new View[]
            {
                new PerformanceView(),
                new StorageView(),
            };

            foreach(var view in views) {
                stack.add_titled(view, view.name, view.title);
                stack.child_set (view, "icon-name", view.icon_name, null);
            }

            stack.notify.connect(() => {
                if(stack.visible_child_name == views[Views.PERFORMANCE].name)
                {
                    header_bar.set_mode(HeaderBarMode.PERFORMANCE);
                }
                else if(stack.visible_child_name == views[Views.STORAGE].name)
                {
                    header_bar.set_mode(HeaderBarMode.STORAGE);
                }
            });

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.visible = true;
            box.add(stack);
            box.add(viewswitcher_bar);
            this.add(box);
        }

        public Usage.HeaderBar get_header_bar()
        {
            return header_bar;
        }

        public View[] get_views()
        {
            return views;
        }

        private void load_css()
        {
            var provider = new Gtk.CssProvider();
            Gtk.StyleContext.reset_widgets(get_screen());
            provider.load_from_resource("/org/gnome/Usage/interface/adwaita.css");
            Gtk.StyleContext.add_provider_for_screen(get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
