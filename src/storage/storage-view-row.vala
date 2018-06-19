/* storage-view-row.vala
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

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-view-row.ui")]
public class Usage.StorageViewRow : Gtk.ListBoxRow {
    public string label {
        set {
            title.label = value;
        }
        get {
            return title.label;
        }
    }

    [GtkChild]
    private Gtk.Label title;

    [GtkChild]
    public Gtk.Label size_label;

    [GtkChild]
    public Gtk.Box tag;

    public enum TagSize {
        SMALL,
        BIG,
    }
    public TagSize tag_size {
        set {
            if (value == TagSize.BIG) {
                tag.width_request = tag.height_request = 20;
            }
        }
        get {
            return (tag.width_request == 20 ? TagSize.BIG : TagSize.SMALL);
        }
    }

    public StorageViewItem item; 

    public StorageViewRow.from_item (StorageViewItem item) {
        this.item = item;

        title.label = item.name;    
        size_label.label = Utils.format_size_values (item.size);

        tag.get_style_context ().add_class (item.style_class);

        if (item.type == FileType.DIRECTORY || item.custom_type != null)
            tag.width_request = tag.height_request = 20;

        if(item.custom_type == "up-folder")
            get_style_context().add_class("up-folder");
    }
}
