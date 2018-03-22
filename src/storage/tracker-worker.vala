/* tracker-worker.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
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
 * Authors: Felipe Borges <felipeborges@gnome.org>
 */

using Tracker;

public class Usage.TrackerWorker {
    private Sparql.Cursor cursor;

    public async TrackerWorker (Sparql.Connection connection, string query) throws GLib.Error {
        cursor = yield connection.query_async (query);
    }

    public async bool fetch_next (out string uri, out string file_type) throws GLib.Error {
        uri = file_type = null;

        if (!(yield cursor.next_async ()))
            return false;

        uri = cursor.get_string (0);
        var type = cursor.get_string (1);
        file_type = type.substring (type.last_index_of_char ('/') + 1, -1);
        if (uri == null)
            return yield fetch_next (out uri, out file_type);

        return true;
    }
}
