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
        get {
            return title.label;
        }
        set {
            title.label = value;
        }
    }

    [GtkChild]
    private unowned Gtk.Label title;

    [GtkChild]
    public unowned Gtk.CheckButton check_button;

    [GtkChild]
    public unowned Gtk.Label size_label;

    [GtkChild]
    public unowned Gtk.Spinner spinner;

    [GtkChild]
    public unowned Gtk.Box tag;

    public enum TagSize {
        SMALL,
        BIG,
    }
    public TagSize tag_size {
        get {
            return (tag.width_request == 20 ? TagSize.BIG : TagSize.SMALL);
        }
        set {
            if (value == TagSize.BIG) {
                tag.width_request = tag.height_request = 20;
            }
        }
    }

    public bool selected {
        get { return check_button.active; }
    }

    public signal void check_button_toggled ();

    public StorageViewItem item;

    public StorageViewRow.from_item (StorageViewItem item) {
        this.item = item;

        var tag_style_context = tag.get_style_context ();
        tag_style_context.add_class (item.style_class);
        item.color = tag_style_context.get_background_color (tag_style_context.get_state ());

        check_button.visible = item.show_check_button;
        check_button.toggled.connect (() => {
            check_button_toggled ();
        });

        item.notify.connect (() => {
            set_up ();
        });
        set_up ();

        if (item.type == FileType.DIRECTORY || item.custom_type != StorageViewType.NONE)
            tag.width_request = tag.height_request = 20;

        if (item.custom_type == StorageViewType.UP_FOLDER) {
            get_style_context ().add_class ("up-folder");

            if (!item.loaded) {
                spinner.visible = true;
                size_label.visible = false;
            }

            item.notify["loaded"].connect (() => {
                if (item.loaded) {
                    spinner.visible = false;
                    size_label.visible = true;
                }
            });
        }
    }

    private void set_up () {
        title.label = item.name;
        size_label.label = Utils.format_size_values (item.size);
        change_color (item.color);
    }

    private void change_color (Gdk.RGBA color) {
        var css_provider = new Gtk.CssProvider ();
        tag.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var css =
        @".row-tag {
            background: $color;
        }";

        try {
            css_provider.load_from_data (css);
        }
        catch (GLib.Error error)    {
            warning ("Failed to color StorageViewRow: %s", error.message);
        }
    }
}
