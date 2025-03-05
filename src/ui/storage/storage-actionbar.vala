/* storage-actionbar.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
 * Copyright (C) 2023 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-actionbar.ui")]
public class Usage.StorageActionBar : Adw.Bin {
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

        ulong most_significant;
        string size_formatted = Utils.format_size_values (size, out most_significant);
        size_label.label = GLib.ngettext("%s selected", "%s selected", most_significant).printf (size_formatted);
    }

    [GtkCallback]
    private void delete_clicked () {
        string display_message = _("Are you sure you want to permanently delete selected items?");
        string display_explanation = _("If you delete these items, they will be permanently lost.");

        Adw.AlertDialog dialog = new Adw.AlertDialog (display_message, display_explanation);

        dialog.add_response ("cancel",  _("Cancel"));
        dialog.add_response ("delete", _("Delete"));

        dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);

        dialog.set_default_response ("cancel");
        dialog.set_close_response ("cancel");

        dialog.response.connect ((dialog, response_type) => {
            switch (response_type) {
                case "replace":
                    foreach (var item in selected_items) {
                        if (item.type == FileType.DIRECTORY && item.custom_type == StorageViewType.ROOT_ITEM)
                            delete_file (item.uri, false);
                        else
                            delete_file (item.uri, true);
                    }
                    refresh_listbox ();
                    break;
                case "cancel":
                default:
                    break;
            }
            dialog.destroy ();
        });
        dialog.present ((Gtk.Window) this.get_root ());
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
