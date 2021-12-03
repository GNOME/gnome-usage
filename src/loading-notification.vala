/* loading-notification.vala
 *
 * Copyright (C) 2019 Red Hat, Inc.
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

[GtkTemplate (ui = "/org/gnome/Usage/ui/loading-notification.ui")]
private class Usage.LoadingNotification: Gtk.Revealer {
    public signal void dismissed ();
    public delegate void DismissFunc ();

    [GtkChild]
    private unowned Gtk.Label message_label;

    public LoadingNotification (string message, owned DismissFunc? dismiss_func) {
        set_reveal_child (true);

        message_label.label = message;

        dismissed.connect ( () => {
            if (dismiss_func != null)
                dismiss_func ();
            set_reveal_child(false);
        });
    }

    public void dismiss() {
        dismissed();
    }
}
