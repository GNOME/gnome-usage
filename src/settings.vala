/* settings.vala
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

public class Usage.Settings : GLib.Settings {
    private Gtk.Settings gtk_settings = Gtk.Settings.get_default ();
    private GLib.PowerProfileMonitor power_profile_monitor = GLib.PowerProfileMonitor.dup_default ();

    public uint graph_timespan { get; set; default = 15000;}
    public uint graph_update_interval { get { return 1000; }}
    public uint list_update_interval_UI { get; set; default = 5000; }
    public uint list_update_pie_charts_UI { get; set; default = 1000; }
    public uint data_update_interval { get; set; default = 1000; }
    public double app_minimum_load { get { return 0.2d; } }
    public double app_minimum_memory { get { return 0; } }
    public bool enable_scrolling_graph {
        get {
            return gtk_settings.gtk_enable_animations
                    && !power_profile_monitor.power_saver_enabled;
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
    }
}
