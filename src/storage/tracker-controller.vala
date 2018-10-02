/* tracker-controller.vala
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

public class Usage.TrackerController : GLib.Object {
    public signal void refresh_model();

    private Sparql.Connection connection;
    private StorageQueryBuilder query_builder;
    private GLib.ListStore model;

    construct {
        query_builder = new StorageQueryBuilder ();
    }

    public TrackerController (Sparql.Connection connection) {
        this.connection = connection;
    }

    public void set_model(GLib.ListStore model) {
        this.model = model;
    }

    public async bool enumerate_children (string uri, UserDirectory? dir, Cancellable cancellable) throws GLib.Error {
        var query = query_builder.enumerate_children (uri);

        var worker = yield new TrackerWorker (connection, query);
        string n_uri = null;
        string file_type = null;

        var parent = File.new_for_uri (uri);
        uint64 parent_size = 1;
        if (parent != null) {
            parent_size = yield get_file_size (uri);
        }

        while (yield worker.fetch_next (out n_uri, out file_type)) {
            try {
                if(!cancellable.is_cancelled()) {
                    var file = File.new_for_uri (n_uri);
                    var item = StorageViewItem.from_file (file);

                    if(item == null)
                        continue;

                    item.ontology = file_type;
                    item.dir = dir;

                    if (item.type == FileType.DIRECTORY) {
                        item.size = yield get_file_size (n_uri);
                    }

                    item.percentage = item.size*100/(double)parent_size;

                    model.insert_sorted (item, (a, b) => {
                        var item_a = a as StorageViewItem;
                        var item_b = b as StorageViewItem;

                        if (item_a.size > item_b.size) {
                            return -1;
                        }

                        if (item_b.size > item_a.size) {
                            return 1;
                        }

                        return 0;
                    });

                    refresh_model();
                } else
                    return false;
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        return true;
    }

    private uint64 get_g_file_size (string uri) {
        try {
            var file = File.new_for_uri (uri);
            var info = file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            return info.get_size ();
        } catch (GLib.Error error) {
             return 0;
        }
    }

    public async uint64 get_file_size (string uri) throws GLib.Error {
        uint64 total = 0;

        var query = query_builder.enumerate_children (uri, true);

        var worker = yield new TrackerWorker (connection, query);

        string n_uri = null;
        while (yield worker.fetch_next (out n_uri, null))
            total += get_g_file_size (n_uri);

        return total;
    }
}
