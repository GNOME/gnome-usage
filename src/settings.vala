/* settings.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023 Markus Göllnitz
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

using Gtk;

public class Usage.Settings : GLib.Settings {
    private Gtk.Settings gtk_settings = Gtk.Settings.get_default ();
    private GLib.PowerProfileMonitor power_profile_monitor = GLib.PowerProfileMonitor.dup_default ();

    public uint graph_timespan { get { return this.settings.get_uint ("performance-graphs-timespan"); } }
    public uint list_update_multiple {
        get {
            return (int) Math.ceil (5000.0 / this.data_update_interval);
        }
    }
    public uint data_update_interval { get { return this.settings.get_uint ("performance-update-interval"); } }
    public double app_minimum_load { get { return this.settings.get_double ("app-minimum-load"); } }
    public double app_minimum_memory { get { return this.settings.get_double ("app-minimum-memory"); } }
    public bool enable_scrolling_graph {
        get {
            return this.gtk_settings.gtk_enable_animations
                    && !this.power_profile_monitor.power_saver_enabled
                    && !this.settings.get_boolean ("disable-scrolling-graphs");
        }
    }

    private static Settings settings;

    public static Settings get_default () {
        if (settings == null)
            settings = new Settings ();

        return settings;
    }

    public Settings () {
        Object (schema_id: Config.APPLICATION_ID);

        this.power_profile_monitor.notify["power-saver-enabled"].connect (() => {
            this.notify_property ("enable-scrolling-graph");
        });

        this.gtk_settings.notify["gtk-enable-animations"].connect (() => {
            this.notify_property ("enable-scrolling-graph");
        });
    }
}
