/* primary-menu.vala
 *
 * Copyright 2018 Christopher Davis <brainblasted@disroot.org>
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
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gtk;

[GtkTemplate (ui="/org/gnome/Usage/ui/primary-menu.ui")]
public class Usage.PrimaryMenu : Gtk.Popover {

    [GtkChild]
    private unowned Gtk.Box performance_container;

    public HeaderBarMode mode { get; set; }

    public PrimaryMenu () {
        notify["mode"].connect ((sender, property) => {
            switch (mode) {
                case HeaderBarMode.PERFORMANCE:
                    performance_container.show ();
                    break;
                case HeaderBarMode.STORAGE:
                    performance_container.hide ();
                    break;
            }
        });
    }
}
