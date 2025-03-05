/* gamemode-monitor.vala
 *
 * Copyright (C) 2025 Markus Göllnitz
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

[DBus (name = "com.feralinteractive.GameMode.Game", timeout = 120000)]
public interface com.feralinteractive.GameMode.Game : Object {

    [DBus (name = "ProcessId")]
    public abstract int process_id { get; }

    [DBus (name = "Executable")]
    public abstract string executable { owned get; }
}

[DBus (name = "com.feralinteractive.GameMode", timeout = 120000)]
public interface com.feralinteractive.GameMode.Client : Object {
    [DBus (name = "ListGames")]
    public abstract GameInfo[] list_games () throws DBusError, IOError;

    [DBus (name = "GameRegistered")]
    public signal void game_registered (int pid, ObjectPath path);

    [DBus (name = "GameUnregistered")]
    public signal void game_unregistered (int pid, ObjectPath path);
}

public struct com.feralinteractive.GameMode.GameInfo {
    public int pid;
    public ObjectPath path;
}

public class Usage.GameModeMonitor : Monitor {
    private com.feralinteractive.GameMode.Client? client;
    private HashTable<int, ObjectPath> pids = new HashTable<int, ObjectPath> (direct_hash, direct_equal);

    public GameModeMonitor () {
        try {
            client = Bus.get_proxy_sync (BusType.SESSION,
                                        "com.feralinteractive.GameMode",
                                        "/com/feralinteractive/GameMode");

            ((!) client).game_registered.connect (this.on_game_registered);
            ((!) client).game_unregistered.connect (this.on_game_unregistered);

            com.feralinteractive.GameMode.GameInfo[] games = client?.list_games ();
            foreach (com.feralinteractive.GameMode.GameInfo info in games) {
                pids.insert (info.pid, info.path);
            }
        } catch (IOError e) {
            warning ("GameMode Proxy creation failed: %s", e.message);
        } catch (GLib.DBusError e) {
            info ("GameMode D-Bus error: %s", e.message);
        }
    }

    public void update () {
    }

    public void update_process (ref Process process) {
        process.gamemode = process.pid in this.pids;
    }

    /* Signals */
    private void on_game_registered (int pid, GLib.ObjectPath path) {
        this.pids.insert (pid, path);
    }

    private void on_game_unregistered (int pid, GLib.ObjectPath path) {
        this.pids.remove (pid);
    }
}
