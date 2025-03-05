/* background-monitor.vala
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

[DBus (name = "org.freedesktop.background.Monitor", timeout = 120000)]
public interface org.freedesktop.background.Monitor : Object {
    [DBus (name = "BackgroundApps")]
    public abstract HashTable<string, Variant?>[] background_apps { owned get; }

    [DBus (name = "version")]
    public abstract uint version { get; }
}

public struct org.freedesktop.background.BackgroundApp {
    public string app_id;
    public string instance;
    public string? message;
}

public class Usage.BackgroundMonitor : Object {
    org.freedesktop.background.Monitor? monitor;

    public BackgroundMonitor () {
        try {
            monitor = Bus.get_proxy_sync (BusType.SESSION,
                                          "org.freedesktop.background.Monitor",
                                          "/org/freedesktop/background/monitor");

            if (monitor?.version > 1) {
                warning ("Usage.BackgroundMonitor only makes use of org.freedesktop.background.Monitor version 1");
            }
        } catch (IOError e) {
            warning ("BackgroundMonitor proxy creation failed: %s", e.message);
        }
    }

    public org.freedesktop.background.BackgroundApp[] get_background_apps () {
        org.freedesktop.background.BackgroundApp[] background_apps = {};
        foreach (HashTable<string, Variant?> app_as_table in monitor?.background_apps) {
            background_apps += org.freedesktop.background.BackgroundApp () {
                app_id = ((!) app_as_table["app_id"]).get_string (),
                instance = ((!) app_as_table["instance"]).get_string (),
                message = app_as_table["message"]?.get_string (),
            };
        }
        return background_apps;
    }
}
