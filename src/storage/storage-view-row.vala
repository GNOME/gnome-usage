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
    public Gtk.CheckButton check_button;

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

    public bool selected {
        get { return check_button.active; }
    }

    public signal void check_button_toggled();

    public StorageViewItem item;

    public StorageViewRow.from_item (StorageViewItem item) {
        this.item = item;

        title.label = item.name;    
        size_label.label = Utils.format_size_values (item.size);

        tag.get_style_context ().add_class (item.style_class);
        check_button.visible = item.show_check_button;
        check_button.toggled.connect(() => {
            check_button_toggled();
        });

        if (item.type == FileType.DIRECTORY || item.custom_type != null)
            tag.width_request = tag.height_request = 20;

        if(item.custom_type == "up-folder")
            get_style_context().add_class("up-folder");
    }

    public void colorize(uint order, uint all_count) {
        if(order == 0)
            return;

        var default_color = tag.get_style_context().get_background_color(get_style_context().get_state());
        var result_color = Utils.generate_color(default_color, order, all_count, true);
        var css_provider = new Gtk.CssProvider();
        tag.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var css =
        @".row-tag {
            background: $result_color;
        }";

        try {
            css_provider.load_from_data(css);
        }
        catch (GLib.Error error)    {
            warning("Failed to color StorageViewRow: %s", error.message);
        }
    }
}
