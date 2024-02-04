/* process-row.vala
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

[GtkTemplate (ui = "/org/gnome/Usage/ui/process-row.ui")]
public class Usage.ProcessRow : Gtk.ListBoxRow {
    public AppItem app { get; private set; }
    public bool max_usage { get; private set; }

    private const string CSS_TAG_USER = "tag-user";
    private const string CSS_TAG_ROOT = "tag-root";
    private const string CSS_TAG_SYSTEM = "tag-system";

    [GtkChild]
    private unowned Gtk.Image icon;

    [GtkChild]
    private unowned Gtk.Label title_label;

    [GtkChild]
    private unowned Usage.ProcessUserTag user_tag;

    [GtkChild]
    private unowned Gtk.Image gamemode;

    [GtkChild]
    private unowned Gtk.Label load_label;

    private ProcessListBoxType type;

    public ProcessRow (AppItem app, ProcessListBoxType type) {
        this.type = type;
        this.app = app;
        this.icon.gicon = app.icon;
        this.app.bind_property ("gamemode", gamemode, "visible", BindingFlags.SYNC_CREATE);
        update ();
    }

    private void update () {
        update_load_label ();
        update_user_tag ();

        title_label.label = app.display_name;
    }

    private void update_load_label () {
        load_label.label = this.type.load_label_factory (app);
    }

    private void update_user_tag () {
        if (app.user == null)
            return;

        remove_user_tag ();
        create_user_tag ();
    }

    private void remove_user_tag () {
        user_tag.visible = false;
    }

    private void create_user_tag () {
        string class_name = "";
        if (app.user.LocalAccount) {
            class_name = CSS_TAG_USER;
        } else if (app.user.AccountType == UserAccountType.ADMINISTRATOR) {
            class_name = CSS_TAG_ROOT;
        } else if (app.user.SystemAccount) {
            class_name = CSS_TAG_SYSTEM;
        }

        user_tag.user_type = class_name;
        user_tag.label = app.user.UserName;
        user_tag.visible = !is_logged_in ();
    }

    private bool is_logged_in (){
        return app.user.UserName == GLib.Environment.get_user_name ();
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
