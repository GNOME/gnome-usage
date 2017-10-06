/* graph-stack-switcher.vala
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
    public class GraphStackSwitcher : Gtk.Box
    {
        View[] sub_views;
        AnimatedScrolledWindow scrolled_window;

        GraphSwitcherButton[] buttons;

        class construct
        {
            set_css_name("graph-stack-switcher");
        }

        public GraphStackSwitcher(AnimatedScrolledWindow scrolled_window, View[] sub_views)
        {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.sub_views = sub_views;
            this.scrolled_window = scrolled_window;

            scrolled_window.scroll_changed.connect(on_scroll_changed);

            buttons = {
                new GraphSwitcherButton.processor(_("Processor")),
                new GraphSwitcherButton.memory(_("Memory"))
            };

            foreach(GraphSwitcherButton button in buttons)
            {
                this.pack_start(button, false, true, 0);

                button.button_release_event.connect(() => {
                    var button_number = get_button_number(button);
                    scroll_to_view(button_number);

                    return false;
                });
            }

            show_all();
        }

        private int get_button_number(Gtk.Button button)
        {
            for(int i = 0; i < buttons.length; i++)
            {
                if(buttons[i] == button)
                    return i;
            }

            return 0;
        }

        private void scroll_to_view(int button_number)
        {
            Gtk.Allocation alloc;

            this.sub_views[button_number].get_allocation(out alloc);
            scrolled_window.animated_scroll_vertically(alloc.y);
        }

        private void on_scroll_changed(double y)
        {
            Gtk.Allocation alloc;

            this.sub_views[1].get_allocation(out alloc);
            var button_number = (y < alloc.y) ? 0 : 1;

            buttons[button_number].set_active(true);
        }
    }
}
