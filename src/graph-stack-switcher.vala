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
        Gtk.Adjustment vadjustment;
        View[] sub_views;

        GraphSwitcherButton[] buttons;

        class construct
        {
            set_css_name("graph-stack-switcher");
        }


        public GraphStackSwitcher(Gtk.ScrolledWindow scrolled_window, View[] sub_views)
        {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.sub_views = sub_views;
            this.vadjustment = scrolled_window.get_vadjustment();

            this.vadjustment.value_changed.connect(on_scroll_changed);

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

            this.vadjustment.set_value(alloc.y);
        }

        private void on_scroll_changed(Gtk.Adjustment adjustment)
        {
            Gtk.Allocation alloc;
            var active_button = 0;

            this.sub_views[1].get_allocation(out alloc);
            active_button = (adjustment.get_value() < alloc.y) ? 0 : 1;

            this.buttons[active_button].set_active(true);
        }
    }
}

