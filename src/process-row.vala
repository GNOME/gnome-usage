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

[GtkTemplate (ui = "/org/gnome/Usage/ui/process-row.ui")]
public class Usage.ProcessRow : Gtk.ListBoxRow {
    public AppItem app { get; private set; }
    public ProcessRowItem item { get; private set; }

    [GtkChild]
    private unowned Usage.ProcessUserTag user_tag;

    public ProcessRow (AppItem app, ProcessListBoxType type) {
        this.app = app;
        this.item = new ProcessRowItem (app, type);
    }

    public new void activate () {
        var settings = Settings.get_default ();
        if (app.representative_cmdline in settings.get_strv ("unkillable-processes"))
            return;

        var dialog = new QuitProcessDialog (app);
        dialog.set_transient_for ((Gtk.Window) this.get_root ());
        dialog.present ();
    }
}

public class Usage.ProcessRowItem : Object {
    private const string CSS_TAG_USER = "tag-user";
    private const string CSS_TAG_ROOT = "tag-root";
    private const string CSS_TAG_SYSTEM = "tag-system";

    private ProcessListBoxType type;

    public AppItem app { get; private set; }

    public virtual string load {
        owned get {
            return this.type.load_label_factory (app);
        }
    }

    public virtual string user {
        owned get {
            if (app.user != null) {
                return app.user.UserName;
            }
            return "";
        }
    }
    public virtual bool not_current_user {
        get {
            return app.user == null || app.user.UserName != GLib.Environment.get_user_name ();
        }
    }
    public virtual string user_type {
        get {
            if (app.user == null) {
                return null;
            }

            if (app.user.LocalAccount) {
                return CSS_TAG_USER;
            } else if (app.user.AccountType == UserAccountType.ADMINISTRATOR) {
                return CSS_TAG_ROOT;
            } else if (app.user.SystemAccount) {
                return CSS_TAG_SYSTEM;
            }

            return null;
        }
    }

    public ProcessRowItem (AppItem app, ProcessListBoxType type) {
        this.app = app;
        this.type = type;
    }
}
