/* application.vala
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

using Gtk;

public class Usage.Application : Adw.Application {
    private Window window;

    private const GLib.ActionEntry app_entries[] = {
        { "about", on_about },
        { "search", on_search },
        { "quit", on_quit },
        { "filter-processes", on_activate_radio, "s", "'group-system'", change_filter_processes_state }
    };

    public Application () {
        Object (application_id: Config.APPLICATION_ID, flags: ApplicationFlags.DEFAULT_FLAGS, resource_base_path: Config.APPLICATION_RESOURCE_PATH);
    }

    public Window? get_window () {
        return window;
    }

    public override void activate () {
        if (window == null)
            window = new Window (this);

        window.present ();
    }

    protected override void startup () {
        base.startup ();

        add_action_entries (app_entries, this);
        set_accels_for_action ("app.search", {"<Control>f"});
        set_accels_for_action ("app.quit", {"<Control>q"});
        Gtk.Window.set_default_icon_name ("org.gnome.Usage");
    }

    private void on_about (GLib.SimpleAction action, GLib.Variant? parameter) {
        string[] authors = {
            "Petr Štětka <pstetka@redhat.com>",
            "Markus Göllnitz <camelcasenick@bewares.it>"
        };
        string[] artists = {
            "Allan Day <aday@gnome.org>",
            "Jon McCann <jmccann@redhat.com>",
            "Jakub Steiner <jsteiner@redhat.com>"
        };

        // TODO: should use Config.APPLICATION_ID, see data/meson.build
        new Adw.AboutDialog.from_appdata (Config.APPLICATION_RESOURCE_PATH + "org.gnome.Usage" + ".metainfo.xml",
                                          Config.VERSION.split ("-")[0]) {
            comments = _("A nice way to view information about use of system resources, like memory and disk space."),
            developers = authors,
            designers = artists,
            translator_credits = _("translator-credits"),
        }.present (window);
    }

    private void on_quit (GLib.SimpleAction action, GLib.Variant? parameter) {
        window.destroy ();
    }

    private void on_search (GLib.SimpleAction action, GLib.Variant? parameter) {
        window.action_on_search ();
    }

    private void on_activate_radio (GLib.SimpleAction action, GLib.Variant? state) {
        action.change_state (state);
    }

    private void change_filter_processes_state (GLib.SimpleAction action, GLib.Variant? state) {
        action.set_state (state);
        SystemMonitor.get_default ().group_system_apps = state.get_string () == "group-system" ? true : false;
    }
}
