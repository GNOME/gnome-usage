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
        Gtk.Stack stack;
        View[] sub_views;

        Gtk.ToggleButton[] buttons;

        bool can_change = true;

		public GraphStackSwitcher(Gtk.Stack stack, View[] sub_views)
		{
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.stack = stack;
            this.sub_views = sub_views;

            buttons = {
                new GraphSwitcherButton.processor(_("Processor")),
                new GraphSwitcherButton.memory(_("Memory")),
                new GraphSwitcherButton.network(_("Network"))
            };

    	    foreach(Gtk.ToggleButton button in buttons)
            {
                this.pack_start(button, false, true, 0);
            }

    	    buttons[0].set_active (true);

            foreach(Gtk.ToggleButton button in buttons)
            {
                button.toggled.connect (() => {
                    if(can_change)
                    {
                        if (button.active)
                        {
                            can_change = false;

                            int i = 0;
                            int button_number = 0;
                            foreach(Gtk.ToggleButton btn in buttons)
                            {
                                if(btn != button)
                                    btn.active = false;
                                else
                                    button_number = i;
                                i++;
                            }
                            this.stack.set_visible_child_name(this.sub_views[button_number].name);
                            /* todo : store the network subview in a var rather than indexing the array*/
                            if( strcmp (this.sub_views[button_number].name, "NETWORK") == 0)
                            {
                                //emit the signal start-capture;
                                this.sub_views[button_number].network_stats_activate();
                            }
                            else
                            {
                                //*TODO* hard coded the network subview for the timebeing
                                this.sub_views[2].network_stats_deactivate();
                            }

                            can_change = true;
                        } 
                        else
                        {
                            can_change = false;
                            button.active = true;
                            can_change = true;
                        }
                    }
                });
            }
        }
    }
}
