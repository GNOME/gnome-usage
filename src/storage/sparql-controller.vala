/* sparql-controller.vala
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

public class Usage.SparqlController : GLib.Object {
    private Tsparql.SparqlConnection connection;
    private StorageQueryBuilder query_builder;
    private GLib.ListStore model;

    construct {
        this.query_builder = new StorageQueryBuilder ();
    }

    public SparqlController (Tsparql.SparqlConnection connection) {
        this.connection = connection;
    }

    public void set_model (GLib.ListStore model) {
        this.model = model;
    }

    public async uint64 enumerate_children (string uri, UserDirectory? dir, Cancellable cancellable) {
        string query = this.query_builder.enumerate_children (uri);

        uint64 uri_size = 0;
        try {

            SparqlWorker worker = yield new SparqlWorker (connection, query);
            string n_uri = null;
            string file_type = null;

            File parent = File.new_for_uri (uri);
            uint64 parent_size = 1;
            if (parent != null)
                parent_size = yield this.get_file_size (uri);

            while (yield worker.fetch_next (out n_uri, out file_type)) {
                if (!cancellable.is_cancelled ()) {
                    File file = File.new_for_uri (n_uri);
                    StorageViewItem item = StorageViewItem.from_file (file);

                    if (item == null)
                        continue;

                    item.ontology = file_type;
                    item.dir = dir;

                    if (item.type == FileType.DIRECTORY) {
                        item.size = yield this.get_file_size (n_uri);
                    }

                    item.percentage = item.size * 100 / (double) parent_size;
                    uri_size += item.size;

                    model.insert_sorted (item, (a, b) => {
                        StorageViewItem item_a = a as StorageViewItem;
                        StorageViewItem item_b = b as StorageViewItem;

                        if (item_a.custom_type == StorageViewType.UP_FOLDER || item_a.size > item_b.size) {
                            return -1;
                        }

                        if (item_b.custom_type == StorageViewType.UP_FOLDER || item_b.size > item_a.size) {
                            return 1;
                        }

                        return 0;
                    });
                } else
                    return uri_size;
            }
        } catch (GLib.Error error) {
            warning (error.message);
        }

        return uri_size;
    }

    private uint64 get_g_file_size (string uri) {
        try {
            File file = File.new_for_uri (uri);
            FileInfo info = file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            return info.get_size ();
        } catch (GLib.Error error) {
             return 0;
        }
    }

    public async uint64 get_file_size (string uri) throws GLib.Error {
        uint64 total = 0;

        string query = this.query_builder.enumerate_children (uri, true);

        SparqlWorker worker = yield new SparqlWorker (connection, query);

        string n_uri = null;
        while (yield worker.fetch_next (out n_uri, null))
            total += this.get_g_file_size (n_uri);

        return total;
    }
}
