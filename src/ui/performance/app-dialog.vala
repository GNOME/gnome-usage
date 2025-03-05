/* app-dialog.vala
 *
 * Copyright (C) 2024 Markus Göllnitz
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
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.AppDialogProperty : Object {
    public string name { get; set; }
    public string @value { get; set; }
}

public class Usage.AppDialogProperties : Object, ListModel {
    private ListStore model = new ListStore (typeof (AppDialogProperty));

    public AppDialogProperties (AppDialogProperty[]? properties = null) {
        foreach (AppDialogProperty property in properties) {
            this.model.append ((Object) property);
        }
        this.model.items_changed.connect (this.items_changed);
    }

    public void append (AppDialogProperty property) {
        this.model.append (property);
    }

    public Object? get_item (uint position) {
        return model.get_item (position);
    }

    public Type get_item_type () {
        return model.get_item_type ();
    }

    public uint get_n_items () {
        return model.get_n_items ();
    }
}

[GtkTemplate (ui = "/org/gnome/Usage/ui/app-dialog.ui")]
public class Usage.AppDialog : Adw.Dialog {
    private AppItem app;

    [GtkChild]
    private unowned Gtk.Image icon;

    [GtkChild]
    private unowned Gtk.Label app_title;

    [GtkChild]
    private unowned Gtk.Label app_user;

    [GtkChild]
    private unowned Gtk.Box in_background_info;

    [GtkChild]
    private unowned Gtk.ListView simple_properties;

    [GtkChild]
    private unowned Gtk.Button quit_button;

    [GtkChild]
    private unowned Gtk.Button force_quit_button;

    static construct {
        add_binding_action (Gdk.Key.Escape, 0, "window.close", null);
    }

    public AppDialog (AppItem app) {
        this.app = app;

        this.app.bind_property ("display_name", this, "title", BindingFlags.SYNC_CREATE);
        this.app.bind_property ("display_name", this.app_title, "label", BindingFlags.SYNC_CREATE);
        this.app_user.label = this.app.user?.RealName ?? "";
        this.app.bind_property ("is_background", this.in_background_info, "visible", BindingFlags.SYNC_CREATE);
        this.app.bind_property ("icon", this.icon, "gicon", BindingFlags.SYNC_CREATE);
        this.quit_button.sensitive = this.app.is_killable ();

        AppDialogProperty cpu_property = new AppDialogProperty () {
            name = _("CPU"),
            @value = "%.1f %%".printf (this.app.cpu_load * 100),
        };
        this.app.notify["cpu-load"].connect (() => {
            cpu_property.@value = "%.1f %%".printf (this.app.cpu_load * 100);
            cpu_property.notify_property ("value");
        });
        AppDialogProperty memory_property = new AppDialogProperty () {
            name = _("Memory"),
            @value = Utils.format_size_values (this.app.mem_usage),
        };
        this.app.notify["mem-usage"].connect (() => {
            memory_property.@value = Utils.format_size_values (this.app.mem_usage);
            memory_property.notify_property ("value");
        });

        this.simple_properties.model = new Gtk.NoSelection (new AppDialogProperties ({
            cpu_property,
            memory_property,
        }));
    }

    [GtkCallback]
    public void quit_clicked (Gtk.Button quit_button) {
        if (this.app.is_killable ()) {
            QuitProcessDialog dialog = new QuitProcessDialog (app);
            dialog.present ((Gtk.Window) this.get_root ());

            dialog.response.connect ((dialog, response_type) => {
                if (response_type == "quit") {
                    this.quit_button.sensitive = false;
                    this.quit_button.set_child (new Adw.Spinner ());

                    this.app.notify["running"].connect (() => {
                        if (!this.app.is_running ()) {
                            this.close ();
                        }
                    });
                    Timeout.add (2 * Settings.get_default ().data_update_interval, () => {
                        this.quit_button.visible = false;
                        this.force_quit_button.visible = true;
                        return false;
                    });
                }
            });
        }
    }

    [GtkCallback]
    public void force_quit_clicked (Gtk.Button quit_button) {
        if (this.app.is_running () && this.app.is_killable ()) {
            this.app.kill (Posix.Signal.KILL);
        }
        this.close ();
    }
}
