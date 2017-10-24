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
        private View[] views;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);

            this.set_default_size(950, 600);
            this.set_size_request(930, 300);
            this.window_position = Gtk.WindowPosition.CENTER;
            this.set_title(_("Usage"));

            load_css();
            Gtk.Settings.get_for_screen(get_screen()).notify["gtk-application-prefer-dark-theme"].connect(() =>
            {
                load_css();
            });

			var stack = new Gtk.Stack();
			header_bar = new Usage.HeaderBar(stack);
			set_titlebar(header_bar);

            views = new View[]
            {
                new PerformanceView(),
                new StorageView(),
            };

            foreach(var view in views)
                stack.add_titled(view, view.name, view.title);

            stack.notify.connect(() => {
                if(stack.visible_child_name == views[Views.PERFORMANCE].name)
                {
                    header_bar.set_mode(HeaderBarMode.PERFORMANCE);
                }
                else if(stack.visible_child_name == views[Views.STORAGE].name)
                {
                    header_bar.set_mode(HeaderBarMode.STORAGE);
                    StorageAnalyzer.get_default().create_cache.begin();
                }
            });

            this.add(stack);
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
            string name_css = "adwaita.css";
            var settings = Gtk.Settings.get_for_screen(get_screen());

            var provider = new Gtk.CssProvider();
            Gtk.StyleContext.reset_widgets(get_screen());
            provider.load_from_resource("/org/gnome/Usage/interface/" + name_css);
            Gtk.StyleContext.add_provider_for_screen(get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
