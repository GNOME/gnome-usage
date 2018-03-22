
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
