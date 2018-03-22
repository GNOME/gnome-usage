/* storage-view.vala
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
 * Authors: Felipe Borges <felipeborges@gnome.org>
 */

using Tracker;
using GTop;

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-view.ui")]
public class Usage.NewStorageView : Usage.View {
    private Sparql.Connection connection;
    private TrackerController controller;
    private StorageQueryBuilder query_builder;

    [GtkChild]
    private Gtk.Label header_label;

    [GtkChild]
    private StorageViewRow used_row;

    [GtkChild]
    private StorageViewRow available_row;

    [GtkChild]
    private Dazzle.StackList listbox;

    [GtkChild]
    private StorageGraph graph;

    private StorageViewRow os_row = new StorageViewRow ();

    private UserDirectory[] xdg_folders = {
        UserDirectory.DOCUMENTS,
        UserDirectory.DOWNLOAD,
        UserDirectory.MUSIC,
        UserDirectory.PICTURES,
        UserDirectory.VIDEOS,
    };

    construct {
        name = "STORAGE";
        title = _("Storage");

        try {
            connection = Sparql.Connection.get ();
        } catch (GLib.Error error) {
            critical ("Failed to connect to Tracker: %s", error.message);
        }

        query_builder = new StorageQueryBuilder ();
        controller = new TrackerController (connection);
    }

    public NewStorageView () {
        listbox.row_activated.connect (on_row_activated);

        setup_header_label ();
        setup_mount_sizes ();
        populate_view ();
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        var storage_row = row as StorageViewRow;

        if (storage_row.item.type == FileType.DIRECTORY) {
            present_dir (storage_row.item.uri);        
        } else {
            graph.queue_draw ();
        }
    }

    private string get_user_special_dir_path (UserDirectory dir) {
        return "file://" + Environment.get_user_special_dir (dir);
    }

    private Gtk.Widget create_file_row (Object obj) {
        var item = obj as StorageViewItem;

        var row = new StorageViewRow.from_item (item);
        row.visible = true;

        if (item.type == FileType.DIRECTORY) {
            controller.get_file_size.begin (item.uri, (obj, res) => {
                try {
                    var size = controller.get_file_size.end (res);
                    row.size_label.label = Utils.format_size_values (size);
                } catch (GLib.Error error) {
                    warning (error.message);
                }
            });
        }

        row.show_all ();
        return row;
    }

    private async void present_dir (string uri) {
        if (connection == null)
            return;

        try {
            var model = yield controller.enumerate_children (uri);

            var file = File.new_for_uri (uri);
            var item = new StorageViewItem.from_file (file);
            var row = new StorageViewRow.from_item (item);

            listbox.push (row, model, create_file_row);

            graph.model = model;
        } catch (GLib.Error error) {
            critical ("Failed to query the store: %s", error.message);
        }
    }

    private void setup_header_label () {
        header_label.label = Environment.get_host_name ();
    }

    private void setup_mount_sizes () {
        uint64 total_used_size = 0;
        uint64 total_free_size = 0;

        MountList mount_list;
        MountEntry[] entries = GTop.get_mountlist (out mount_list, false);

        for (int i = 0; i < mount_list.number; i++) {
            string dir = (string) entries[i].mountdir;

            FsUsage mount;
            GTop.get_fsusage (out mount, dir);

            var total = mount.blocks * mount.block_size;
            var free = mount.bfree * mount.block_size;
            var used = total - free;

            if (dir == "/") {
                os_row.label = _("Operating System");
                os_row.tag_size = StorageViewRow.TagSize.BIG;
                os_row.get_style_context ().add_class ("stack-children");
                os_row.tag.get_style_context ().add_class ("os-tag");
                os_row.size_label.label = Utils.format_size_values (used);
            }

            total_used_size += used;
            total_free_size += free;
        }

        used_row.size_label.label = Utils.format_size_values (total_used_size);
        used_row.tag.get_style_context ().add_class ("used-tag");

        available_row.size_label.label = Utils.format_size_values (total_free_size);
        available_row.tag.get_style_context ().add_class ("available-tag");
    }

    private async void populate_view () {
        if (connection == null)
            return;

        var model = new GLib.ListStore (typeof (StorageViewItem));
        foreach (var dir in xdg_folders) {
            var file = File.new_for_uri (get_user_special_dir_path (dir));
            var item = new StorageViewItem.from_file (file);
            item.dir = dir;

            model.append (item);
        }

        listbox.push (os_row, model, create_file_row);
        graph.model = model;
    }
}
