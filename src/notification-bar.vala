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

namespace Usage {
    private class NotificationBar: Gtk.Grid {
        public const int DEFAULT_TIMEOUT = 6;
        private const int MAX_NOTIFICATIONS = 5;
        private GLib.List<Widget> active_notifications = new GLib.List<Widget> ();

        public LoadingNotification display_loading (string message, owned LoadingNotification.DismissFunc? dismiss_func) {
            var notification = new LoadingNotification (message, (owned) dismiss_func);
            active_notifications.prepend (notification);

            notification.dismissed.connect ( () => {
                active_notifications.remove (notification);
            });

            add_notification (notification);
            return notification;
        }

        private void add_notification (Widget widget) {
            add (widget);
        }
    }
}
