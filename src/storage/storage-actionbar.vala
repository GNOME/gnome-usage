/* storage-actionbar.vala
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-actionbar.ui")]
public class Usage.StorageActionBar : Gtk.ActionBar {
    private unowned List<StorageViewItem> selected_items;

    [GtkChild]
    private unowned Gtk.Label size_label;

    public signal void refresh_listbox ();

    public void update_selected_items (List<StorageViewItem> selected_items) {
        this.selected_items = selected_items;

        uint64 size = 0;
        foreach (var item in selected_items) {
            size += item.size;
        }
        size_label.label = _("%s selected").printf (Utils.format_size_values (size));
    }

    [GtkCallback]
    private void delete_clicked () {
        var application = GLib.Application.get_default () as Application;
        string display_message = _("Are you sure you want to permanently delete selected items?");

        if (application == null)
            return;

        var dialog = new Gtk.MessageDialog (application.get_window (), Gtk.DialogFlags.MODAL,
            Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, display_message);
        dialog.secondary_text = _("If you delete these items, they will be permanently lost.");

        if (dialog.run () == Gtk.ResponseType.OK) {
            foreach (var item in selected_items) {
                if (item.type == FileType.DIRECTORY && item.custom_type == StorageViewType.ROOT_ITEM)
                    delete_file (item.uri, false);
                else
                    delete_file (item.uri, true);
            }
            refresh_listbox ();
        }
        dialog.destroy ();
    }

    private void delete_file (string uri, bool delete_basefile) {
        var file = File.new_for_uri (uri);
        var type = file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

        try {
            if (type == FileType.DIRECTORY) {
                FileInfo info;
                FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);

                while ((info = enumerator.next_file (null)) != null) {
                    var child = file.get_child (info.get_name ());
                    delete_file (child.get_uri (), true);
                }
            }

            if (delete_basefile)
                file.@delete ();
        }
        catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
