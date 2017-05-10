/* storage-list-box.vala
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

namespace Usage
{
    public class StorageListBox : Gtk.ListBox
    {
        public signal void loading();
        public signal void loaded();
        public signal void empty();

        private List<string?> path_history;
        private List<string?> name_history;
        private List<StorageItemType?> parent_type_history;
        private string? actual_path;
        private string? actual_name;
        private StorageItemType? actual_parent_type;
        private ListStore model;
        private bool root = true;
        private StorageAnalyzer storage_analyzer;
        private Gdk.RGBA color;

        public StorageListBox()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);

            model = new ListStore(typeof(StorageItem));
            bind_model(model, on_row_created);

            row_activated.connect(on_row_activated);
            selected_rows_changed.connect(on_selected_rows_changed);

            path_history = new List<string>();
            name_history = new List<string>();
            parent_type_history = new List<StorageItemType?>();
            actual_path = null;
            actual_name = null;
            actual_parent_type = null;
            storage_analyzer = (GLib.Application.get_default() as Application).get_storage_analyzer();

            get_style_context().add_class("folders");
            color = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("folders");
            reload();
        }

        public ListStore get_model()
        {
            return model;
        }

        public bool get_root()
        {
            return root;
        }

        public void on_back_button_clicked()
        {
            unowned List<string>? path = path_history.last();
            unowned List<string>? name = name_history.last();
            unowned List<StorageItemType?>? parent = parent_type_history.last();
            actual_path = path.data;
            actual_name = name.data;
            actual_parent_type = parent.data;

            load(path.data, actual_parent_type);

            path_history.delete_link(path);
            name_history.delete_link(name);
            parent_type_history.delete_link(parent);
            if(root)
            {
                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_back_button(false);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().set_title_text("");
                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_stack_switcher();
            }
            else
            {
                (GLib.Application.get_default() as Application).get_window().get_header_bar().set_title_text(actual_name);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_title();
                if(actual_parent_type == StorageItemType.TRASHFILE || actual_parent_type == StorageItemType.TRASHSUBFILE)
                    (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_select_button(false);
                else
                    (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_select_button(true);
            }
        }

        public void reload()
        {
            this.hide();
            loading();
            storage_analyzer.cache_complete.connect(() => {
                storage_analyzer.prepare_items.begin(actual_path, color, actual_parent_type, (obj, res) => {
                    var header_bar = (GLib.Application.get_default() as Application).get_window().get_header_bar();
                    if(root == false)
                    {
                        header_bar.show_storage_back_button(true);
                        if(header_bar.get_mode() == HeaderBarMode.STORAGE)
                        {
                            header_bar.set_title_text(actual_name);
                            header_bar.show_title();
                        }
                    }

                    header_bar.show_storage_rescan_button(true);
                    if(actual_parent_type != StorageItemType.TRASHFILE && actual_parent_type != StorageItemType.TRASHSUBFILE)
                        (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_select_button(true);

                    loaded();
                    this.show();
                    model.remove_all();

                    foreach(unowned StorageItem item in storage_analyzer.prepare_items.end(res))
                        model.append(item);

                    if(model.get_n_items() == 0)
                        empty();
                });
            });
        }

        public void refresh()
        {
            load(actual_path, actual_parent_type);
        }

        public void set_select_mode(bool select_mode)
        {
            if(select_mode)
            {
                set_selection_mode (Gtk.SelectionMode.MULTIPLE);
                this.forall ((child) => {
                    var row = child as StorageRow;
                    if (row == null)
                        return;

                    row.set_show_check_button(true);
                });

                if(root)
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_action_bar().show_root();
                else if(actual_parent_type == StorageItemType.TRASH)
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_action_bar().show_trash();
                else if(actual_parent_type != StorageItemType.TRASHFILE && actual_parent_type != StorageItemType.TRASHSUBFILE)
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_action_bar().show_common();

                on_selected_rows_changed();
            }
            else
            {
                set_selection_mode (Gtk.SelectionMode.NONE);
                this.forall ((child) => {
                    var row = child as StorageRow;
                    if (row == null)
                        return;

                    row.set_show_check_button(false);
                });
            }
        }

        public bool get_select_mode()
        {
            if(get_selection_mode() == Gtk.SelectionMode.MULTIPLE)
                return true;
            else
                return false;
        }

        public void select_all_rows()
        {
            if(get_select_mode())
            {
                this.forall ((child) => {
                    var row = child as StorageRow;
                    if (row == null)
                        return;

                    row.set_selected(true);
                    select_row((Gtk.ListBoxRow) row);
                });
            }
        }

        public void unselect_all_rows()
        {
            if(get_select_mode())
            {
                this.forall ((child) => {
                    var row = child as StorageRow;
                    if (row == null)
                        return;

                    row.set_selected(false);
                    unselect_row((Gtk.ListBoxRow) row);
                });
            }
        }

        private void load(string? path, StorageItemType? parent)
        {
            if(path == null)
            {
                root = true;
                get_style_context().add_class("folders");
                color = get_style_context().get_color(get_style_context().get_state());
                get_style_context().remove_class("folders");
            }
            else
                root = false;

            this.hide();
            loading();
            storage_analyzer.prepare_items.begin(path, color, parent, (obj, res) => {
                loaded();
                this.show();
                model.remove_all();

                foreach(unowned StorageItem item in storage_analyzer.prepare_items.end(res))
                    model.append(item);

                if(model.get_n_items() == 0)
                    empty();
            });
        }
        private void on_row_activated (Gtk.ListBoxRow row)
        {
            StorageRow storage_row = (StorageRow) row;
            if(get_select_mode())
            {
                if(storage_row.get_selected())
                {
                    storage_row.set_selected(false);
                    unselect_row(row);
                }
                else
                {
                     storage_row.set_selected(true);
                     select_row(row);
                }
            }
            else
                action_primary(storage_row);
        }

        private void action_primary (StorageRow storage_row)
        {
            if(storage_row.get_item_type() != StorageItemType.STORAGE && storage_row.get_item_type() != StorageItemType.SYSTEM &&
                storage_row.get_item_type() != StorageItemType.AVAILABLE && storage_row.get_item_type() != StorageItemType.FILE)
            {
                path_history.append(actual_path);
                name_history.append(actual_name);
                parent_type_history.append(actual_parent_type);
                actual_path = storage_row.get_item_path();
                actual_name = storage_row.get_item_name();
                actual_parent_type = storage_row.get_parent_type();

                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_back_button(true);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().set_title_text(actual_name);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_title();
                if(actual_parent_type == StorageItemType.TRASHFILE || actual_parent_type == StorageItemType.TRASHSUBFILE)
                    (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_select_button(false);

                if(root)
                    color = storage_row.get_color();

                load(actual_path, actual_parent_type);
            }
            else
                storage_row.action_primary();
        }

        protected override bool button_release_event (Gdk.EventButton event)
        {
            switch (event.button)
            {
            case Gdk.BUTTON_PRIMARY:

                // Necessary to avoid treating an event from a child widget which would mess with getting the correct row.
                if (event.window != this.get_window ())
                     return false;

                var row = this.get_row_at_y ((int) event.y);
                if (row == null)
                    return false;

                StorageRow storage_row = (StorageRow) row;

                if(get_select_mode())
                {
                    if(storage_row.get_selected())
                    {
                        storage_row.set_selected(false);
                        unselect_row(row);
                    }
                    else
                    {
                         storage_row.set_selected(true);
                         select_row(row);
                    }
                }
                else
                    action_primary(storage_row);

                return true;
            case Gdk.BUTTON_SECONDARY:
                // Necessary to avoid treating an event from a child widget which would mess with getting the correct row.
                if (event.window != this.get_window ())
                     return false;

                var row = this.get_row_at_y ((int) event.y);
                if (row == null)
                    return false;

                StorageRow storage_row = (StorageRow) row;
                storage_row.action_secondary();
                return true;
            default:
                return false;
            }
        }

        private void on_selected_rows_changed()
        {
            (GLib.Application.get_default() as Application).get_window().get_header_bar().change_selected_items(get_selected_rows().length());
            if(get_selected_rows().length() > 0)
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_action_bar().set_sensitive_all(true);
            else
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_action_bar().set_sensitive_all(false);
        }

        private Gtk.Widget on_row_created(Object item)
        {
            unowned StorageItem storage_item = (StorageItem) item;
            var row = new StorageRow(storage_item);
            return row;
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
        {
         	if(before_row == null)
                row.set_header(null);
            else
            {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
                separator.get_style_context().add_class("list");
            	separator.show();
        	    row.set_header(separator);
        	}
        }
    }
}
