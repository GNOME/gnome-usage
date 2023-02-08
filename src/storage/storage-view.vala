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
 *          Petr Štětka <pstetka@redhat.com>
 */

using Tracker;
using GTop;

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-view.ui")]
public class Usage.StorageView : Usage.View {
    public const uint MIN_PERCENTAGE_SHOWN_FILES = 2;

    [GtkChild]
    private unowned Gtk.Label header_label;

    [GtkChild]
    private unowned StorageViewRow used_row;

    [GtkChild]
    private unowned StorageViewRow available_row;

    [GtkChild]
    private unowned StackList listbox;

    [GtkChild]
    private unowned StorageGraph graph;

    [GtkChild]
    private unowned StorageActionBar actionbar;

    [GtkChild]
    private unowned NotificationBar notificationbar;

    [GtkChild]
    private unowned StorageRowPopover row_popover;

    private Sparql.Connection connection;
    private TrackerController controller;
    private StorageQueryBuilder query_builder;

    private StorageViewItem os_item = new StorageViewItem ();
    private Cancellable cancellable = new Cancellable ();

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

    private List<StorageViewItem> selected_items = new List<StorageViewItem> ();
    private Queue<List> selected_items_stack = new Queue<List> ();

    construct {
        name = "STORAGE";
        title = _("Storage");
        icon_name = "drive-harddisk-symbolic";

        try {
            connection = Sparql.Connection.bus_new ("org.freedesktop.Tracker3.Miner.Files", null, null);
        } catch (GLib.Error error) {
            critical ("Failed to connect to Tracker Miner FS: %s", error.message);
        }

        query_builder = new StorageQueryBuilder ();
        controller = new TrackerController (connection);

        listbox.init (create_file_row);
        listbox.model_changed.connect ((model) => {
            graph.model = model;
        });

        actionbar.refresh_listbox.connect (this.refresh_current_dir);
    }

    public StorageView () {
        graph.min_percentage_shown_files = MIN_PERCENTAGE_SHOWN_FILES;

        setup_header_label ();
        setup_mount_sizes ();
        populate_view.begin ();
    }

    [GtkCallback]
    private void on_row_activated (Gtk.ListBoxRow row) {
        var storage_row = row as StorageViewRow;

        cancellable.cancel ();
        cancellable = new Cancellable ();

        if (storage_row.item.custom_type == StorageViewType.UP_FOLDER) {
            stack_listbox_up ();
        } else if (storage_row.item.type == FileType.DIRECTORY) {
            selected_items_stack.push_head ((owned) selected_items);
            clear_selected_items ();
            present_dir.begin (storage_row.item.uri, storage_row.item.dir, cancellable);
        } else if (storage_row.item.custom_type != StorageViewType.NONE) {
            row_popover.popup_on_row (storage_row);
        } else {
            try {
                AppInfo.launch_default_for_uri (storage_row.item.uri, null);
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }
    }

    private void stack_listbox_up () {
        selected_items = selected_items_stack.pop_head ();
        refresh_actionbar ();
        listbox.layer_up ();

        var first_item = listbox.get_model ().get_item (0) as StorageViewItem;

        if (listbox.get_depth () > 1 && first_item.loaded == false) {
            this.refresh_current_dir ();
        }
    }

    private string get_user_special_dir_path (UserDirectory dir) {
        return "file://" + Environment.get_user_special_dir (dir);
    }

    private Gtk.Widget create_file_row (Object obj) {
        var item = obj as StorageViewItem;
        var row = new StorageViewRow.from_item (item);
        row.visible = true;

        if (selected_items.find (item) != null)
            row.check_button.active = true;

        row.check_button_toggled.connect ((row) => {
            if (row.selected)
                selected_items.append (row.item);
            else
                selected_items.remove (row.item);

            refresh_actionbar ();
        });

        if (item.custom_type == StorageViewType.AVAILABLE_GRAPH)
            return new Gtk.ListBoxRow ();

        return row;
    }

    private void refresh_current_dir () {
        var item = listbox.get_model ().get_item (0) as StorageViewItem;

        clear_selected_items ();
        listbox.layer_up ();

        if (listbox.get_depth () == 0)
            populate_view.begin ();
        else
            present_dir.begin (item.uri, item.dir, cancellable);
    }

    private async void present_dir (string uri, UserDirectory? dir, Cancellable cancellable) {
        if (connection == null || cancellable.is_cancelled ())
            return;

        var model = new GLib.ListStore (typeof (StorageViewItem));
        var file = File.new_for_uri (uri);
        var item = StorageViewItem.from_file (file);
        item.custom_type = StorageViewType.UP_FOLDER;
        item.dir = dir;
        model.insert (0, item);

        controller.set_model (model);
        controller.enumerate_children.begin (uri, dir, cancellable, (obj, res) => {
            if (!cancellable.is_cancelled ()) {
                var up_folder_item = model.get_item (0) as StorageViewItem;
                up_folder_item.size = controller.enumerate_children.end (res);
                up_folder_item.loaded = true;
            }
        });

        listbox.push_layer (model);
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
                os_item.custom_type = StorageViewType.OS;
            }

            total_used_size += used;
            total_free_size += free;
        }

        os_item.percentage = os_item.size * 100 / (double) total_used_size;
        total_size = total_used_size + total_free_size;

        var total_used_percentage = ((double) total_used_size / total_size) * 100;
        var total_free_percentage = ((double) total_free_size / total_size) * 100;

        total_used_percentage = Math.round (total_used_percentage);
        total_free_percentage = Math.round (total_free_percentage);

        used_row.size_label.label = Utils.format_size_values (total_used_size) + " (%d%)".printf ((int) total_used_percentage);
        used_row.tag.get_style_context ().add_class ("used-tag");

        available_row.size_label.label = Utils.format_size_values (total_free_size) + " (%d%)".printf ((int) total_free_percentage);
        available_row.tag.get_style_context ().add_class ("available-tag");
    }

    private async void populate_view () {
        var loading_notification = notificationbar.display_loading (_("Scanning directories"), null);

        if (connection == null)
            return;

        var model = new GLib.ListStore (typeof (StorageViewItem));
        model.append (os_item);

        var items_loaded = 0;

        foreach (var dir in xdg_folders) {
            var file = File.new_for_uri (get_user_special_dir_path (dir));
            var item = StorageViewItem.from_file (file);
            item.dir = dir;

            controller.get_file_size.begin (item.uri, (obj, res) => {
                try {
                    item.size = controller.get_file_size.end (res);
                    item.percentage = item.size * 100 / (double) total_size;
                    item.custom_type = StorageViewType.ROOT_ITEM;
                    model.insert (1, item);

                    items_loaded++;
                    if (items_loaded == xdg_folders.length)
                        loading_notification.dismiss ();
                } catch (GLib.Error error) {
                    warning (error.message);
                }
            });
        }

        listbox.push_layer (model);

        var available_graph_item = new StorageViewItem ();
        available_graph_item.size = total_free_size;
        available_graph_item.custom_type = StorageViewType.AVAILABLE_GRAPH;
        available_graph_item.percentage = available_graph_item.size * 100 / (double) total_size;
        model.append (available_graph_item);
    }

    private void refresh_actionbar () {
        actionbar.update_selected_items (selected_items);
        graph.update_selected_items (selected_items);

        if (selected_items.length () == 0)
            actionbar.hide ();
        else
            actionbar.show ();
    }

    private void clear_selected_items () {
        selected_items = new List<StorageViewItem>();
        refresh_actionbar ();
    }
}
