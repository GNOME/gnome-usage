/* process-row.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023-2024 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.ProcessRowItem : Object {
    private const string CSS_TAG_USER = "tag-user";
    private const string CSS_TAG_ROOT = "tag-root";
    private const string CSS_TAG_SYSTEM = "tag-system";

    private ProcessListBoxType type;

    public AppItem app { get; private set; }

    public Gtk.Widget load_widget {
        owned get {
            return this.type.load_widget_factory (app);
        }
    }

    public string user {
        owned get {
            return this.app.user?.username ?? "";
        }
    }
    public bool not_current_user {
        get {
            return this.app.user?.username != Environment.get_user_name ();
        }
    }
    public string? user_type {
        get {
            if (this.app.user == null) {
                return null;
            }

            if (this.app.user?.is_local == true) {
                return CSS_TAG_USER;
            } else if (this.app.user?.account_type == User.AccountType.ADMINISTRATOR) {
                return CSS_TAG_ROOT;
            } else if (this.app.user?.is_system_user == true) {
                return CSS_TAG_SYSTEM;
            }

            return null;
        }
    }
    public Icon? container_icon {
        owned get {
            string? container = this.app.container;
            if (container == null) {
                return null;
            }
            switch ((!) container) {
                case "Waydroid":
                    return new GLib.ThemedIcon ("android-app-symbolic");
                default:
                    return null;
            }
        }
    }

    public ProcessRowItem (AppItem app, ProcessListBoxType type) {
        this.app = app;
        this.type = type;
    }
}
