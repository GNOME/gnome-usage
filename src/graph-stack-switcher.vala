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
        private const int BOTTOM_TOLERANCE = 150;

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
                new GraphSwitcherButton.memory(_("Memory")),
                new GraphSwitcherButton.disk(_("Disk I/O"))
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
            var button_number = 0;
            Gtk.Allocation container_alloc;
            sub_views[0].parent.parent.get_allocation(out container_alloc);

            for(int i = 0; i < sub_views.length; i++) {
                Gtk.Allocation sub_view_alloc;
                sub_views[i].get_allocation(out sub_view_alloc);

                if(y + container_alloc.height / 2 < sub_view_alloc.y + sub_view_alloc.height) {
                    button_number = i;
                    break;
                }
            }

            var last_subview_number = sub_views.length - 1;
            Gtk.Allocation last_subview_alloc;
            sub_views[last_subview_number].get_allocation(out last_subview_alloc);

            if(y < BOTTOM_TOLERANCE)
                button_number = 0;
            else if(y + container_alloc.height > last_subview_alloc.y + last_subview_alloc.height - BOTTOM_TOLERANCE)
                button_number = last_subview_number;

            buttons[button_number].set_active(true);
        }
    }
}
