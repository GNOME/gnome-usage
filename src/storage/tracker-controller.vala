using Tracker;

public class Usage.TrackerController : GLib.Object {
    private Sparql.Connection connection;
    private StorageQueryBuilder query_builder;

    construct {
        query_builder = new StorageQueryBuilder ();
    }

    public TrackerController (Sparql.Connection connection) {
        this.connection = connection;
    }

    public async GLib.ListStore enumerate_children (string uri) throws GLib.Error {
        var list = new GLib.ListStore (typeof (StorageViewItem));

        var query = query_builder.enumerate_children (uri);

        var worker = yield new TrackerWorker (connection, query);
        string n_uri = null;
        string file_type = null;

        while (yield worker.fetch_next (out n_uri, out file_type)) {
            try {
                var file = File.new_for_uri (n_uri);
                var item = new StorageViewItem.from_file (file);
                item.ontology = file_type;

                list.insert_sorted (item, (a, b) => {
                    var item_a = a as StorageViewItem;
                    var item_b = b as StorageViewItem;

                    if (item_a.type == FileType.DIRECTORY) {
                        return -1;
                    }

                    if (item_b.type == FileType.DIRECTORY) {
                        return 1;
                    }

                    return 0;
                });
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        return list;
    }

    private uint64 get_g_file_size (string uri) {
        try {
            var file = File.new_for_uri (uri);
            var info = file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            return info.get_size ();
        } catch (GLib.Error error) {
            warning (error.message);
        }

        return 0;
    }

    public async uint64 get_file_size (string uri) throws GLib.Error {
        uint64 total = 0;

        var query = query_builder.enumerate_children (uri, true);

        var worker = yield new TrackerWorker (connection, query);

        string n_uri = null;
        while (yield worker.fetch_next (out n_uri, null)) {
            try {
                total += get_g_file_size (n_uri);
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        return total;
    }
}
