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
    public const uint MIN_PERCENTAGE_SHOWN_FILES = 2;

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

    private StorageViewItem os_item = new StorageViewItem ();
    private StorageRowPopover row_popover = new StorageRowPopover();
    private uint storage_row_i = 0;
    private uint? shown_rows_number = null;

    private uint64 total_used_size = 0;
    private uint64 total_free_size = 0;
    private uint64 total_size = 0;

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
        graph.min_percentage_shown_files = MIN_PERCENTAGE_SHOWN_FILES;

        setup_header_label ();
        setup_mount_sizes ();
        populate_view.begin ();
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        var storage_row = row as StorageViewRow;

        if(storage_row.item.custom_type == "up-folder") {
            shown_rows_number = null;
            storage_row_i = 0;
            listbox.pop();
            graph.model = (ListStore) listbox.get_model();
        } else if (storage_row.item.type == FileType.DIRECTORY) {
            present_dir.begin (storage_row.item.uri, storage_row.item.dir);
        } else if (storage_row.item.custom_type != null) {
            row_popover.present(storage_row);
        }
    }

    private string get_user_special_dir_path (UserDirectory dir) {
        return "file://" + Environment.get_user_special_dir (dir);
    }

    private Gtk.Widget create_file_row (Object obj) {
        var model = listbox.get_model();
        var item = obj as StorageViewItem;
        var row = new StorageViewRow.from_item (item);
        row.visible = true;

        if(item.custom_type == "available-graph")
            return new Gtk.ListBoxRow();

        if(shown_rows_number == null) {
            shown_rows_number = 0;

            for(int i = 0; i < model.get_n_items(); i++) {
                if((model.get_item(i) as StorageViewItem).percentage > MIN_PERCENTAGE_SHOWN_FILES)
                    shown_rows_number = shown_rows_number + 1;
            }

            if(shown_rows_number <= 3) {
                shown_rows_number = model.get_n_items();
            }
        }

        if(listbox.get_depth() > 1)
            row.colorize(storage_row_i, shown_rows_number);

        storage_row_i++;

        return row;
    }

    private async void present_dir (string uri, UserDirectory? dir) {
        if (connection == null)
            return;

        try {
            var model = yield controller.enumerate_children (uri, dir);

            var file = File.new_for_uri (uri);
            var item = new StorageViewItem.from_file (file);
            item.custom_type = "up-folder";
            item.dir = dir;
            controller.get_file_size.begin (item.uri, (obj, res) => {
                try {
                    item.size = controller.get_file_size.end (res);
                    item.percentage = item.size * 100 / (double) total_size;
                    model.insert(0, item);

                    shown_rows_number = null;
                    storage_row_i = 0;

                    listbox.push (new Gtk.ListBoxRow(), model, create_file_row);
                    graph.model = model;
                } catch (GLib.Error error) {
                    warning (error.message);
                }
            });


        } catch (GLib.Error error) {
            critical ("Failed to query the store: %s", error.message);
        }
    }

    private void setup_header_label () {
        header_label.label = Environment.get_host_name ();
    }

    private void setup_mount_sizes () {
        total_used_size = 0;
        total_free_size = 0;

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
                os_item.name = _("Operating System");
                os_item.size = used;
                os_item.custom_type = "os";
            }

            total_used_size += used;
            total_free_size += free;
        }

        os_item.percentage = os_item.size * 100 / (double) total_used_size;
        total_size = total_used_size + total_free_size;

        var total_used_percentage = ((double) total_used_size / total_size) * 100;
        var total_free_percentage = ((double) total_free_size / total_size) * 100;

        total_used_percentage = Math.round(total_used_percentage);
        total_free_percentage = Math.round(total_free_percentage);

        used_row.size_label.label = Utils.format_size_values (total_used_size) + " (%d%)".printf((int) total_used_percentage);
        used_row.tag.get_style_context ().add_class ("used-tag");

        available_row.size_label.label = Utils.format_size_values (total_free_size) + " (%d%)".printf((int) total_free_percentage);
        available_row.tag.get_style_context ().add_class ("available-tag");
    }

    private async void populate_view () {
        if (connection == null)
            return;

        var model = new GLib.ListStore (typeof (StorageViewItem));
        model.append(os_item);

        foreach (var dir in xdg_folders) {
            var file = File.new_for_uri (get_user_special_dir_path (dir));
            var item = new StorageViewItem.from_file (file);
            item.dir = dir;

            controller.get_file_size.begin (item.uri, (obj, res) => {
                try {
                    item.size = controller.get_file_size.end (res);
                    item.percentage = item.size * 100 / (double) total_size;
                    model.insert (1, item);
                } catch (GLib.Error error) {
                    warning (error.message);
                }
            });
        }

        listbox.push (new Gtk.ListBoxRow(), model, create_file_row);
        graph.model = model;

        var available_graph_item = new StorageViewItem ();
        available_graph_item.size = total_free_size;
        available_graph_item.custom_type = "available-graph";
        available_graph_item.percentage = available_graph_item.size * 100 / (double) total_size;
        graph.model.append(available_graph_item);
    }
}
