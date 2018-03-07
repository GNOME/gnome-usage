/* storage-row.vala
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
    public class StorageRow : Gtk.ListBoxRow
    {
        private StorageItemType type;
        private StorageItemType? parent_type;
        private string item_path;
        private string item_name;
        private Gdk.RGBA color;
        private Gtk.CheckButton? check_button;

 		const GLib.ActionEntry[] action_entries = {
           { "rename", action_rename },
           { "move", action_move },
           { "move-to-trash", action_move_to_trash },
           { "delete", action_delete },
           { "wipe-trash", action_wipe_trash },
           { "wipe-folder", action_wipe_folder },
           { "trash-restore", action_trash_restore },
           { "trash-delete", action_trash_delete }
        };

        public StorageRow(StorageItem storage_item)
        {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 10;
            box.margin_top = 12;
            box.margin_bottom = 12;
            var size_label = new Gtk.Label(Utils.format_size_values(storage_item.get_size()));
            item_path = storage_item.get_path();
            item_name = storage_item.get_name();
            parent_type = storage_item.get_parent_type();
            type = storage_item.get_item_type();
            var title_label = new Gtk.Label(storage_item.get_name());
            title_label.set_ellipsize(Pango.EllipsizeMode.MIDDLE);

            Gtk.Widget? icon = null;
            switch(storage_item.get_item_type())
            {
                case StorageItemType.SYSTEM:
                    icon = new ColorRectangle.new_from_css("system");
                    color = (icon as ColorRectangle).color;
                    selectable = false;
                    break;
                case StorageItemType.TRASH:
                    check_button = new Gtk.CheckButton();
                    icon = new ColorRectangle.new_from_css("trash");
                    color = (icon as ColorRectangle).color;
                    break;
                case StorageItemType.USER:
                    check_button = new Gtk.CheckButton();
                    icon = new ColorRectangle.new_from_css("user");
                    color = (icon as ColorRectangle).color;
                    break;
                case StorageItemType.AVAILABLE:
                    icon = new ColorRectangle.new_from_css("available-storage");
                    color = (icon as ColorRectangle).color;
                    selectable = false;
                    break;
                case StorageItemType.STORAGE:
                    title_label.set_markup ("<b>" + storage_item.get_name() + "</b>");
                    size_label.set_markup ("<b>" + Utils.format_size_values(storage_item.get_size()) + "</b>");
                    activatable = false;
                    selectable = false;
                    break;
                case StorageItemType.DOCUMENTS:
                case StorageItemType.DOWNLOADS:
                case StorageItemType.DESKTOP:
                case StorageItemType.MUSIC:
                case StorageItemType.PICTURES:
                case StorageItemType.VIDEOS:
                    check_button = new Gtk.CheckButton();
                    get_style_context().add_class("folders");
                    color = get_style_context().get_color(get_style_context().get_state());
                    get_style_context().remove_class("folders");
                    icon = new ColorRectangle.new_from_rgba(storage_item.get_color());
                    break;
                case StorageItemType.DIRECTORY:
                    check_button = new Gtk.CheckButton();
                    color = storage_item.get_color();
                    var info = Gtk.IconTheme.get_default().lookup_icon("folder-symbolic", 15, 0);

                    try {
                        var pixbuf = info.load_symbolic (storage_item.get_color());
                        icon = new Gtk.Image.from_pixbuf (pixbuf);
                    }
                    catch(Error e) {
                        GLib.stderr.printf ("Could not load folder-symbolic icon: %s\n", e.message);
                    }
                    break;
                 case StorageItemType.FILE:
                    check_button = new Gtk.CheckButton();
                    color = storage_item.get_color();
                    var info = Gtk.IconTheme.get_default().lookup_icon("folder-documents-symbolic", 15, 0);

                    try {
                        var pixbuf = info.load_symbolic (storage_item.get_color());
                        icon = new Gtk.Image.from_pixbuf (pixbuf);
                    }
                    catch(Error e) {
                        GLib.stderr.printf ("Could not load folder-documents-symbolic icon: %s\n", e.message);
                    }
                    break;
            }

            if(check_button != null)
            {
                check_button.toggled.connect(() => {
                    if(check_button.get_active())
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().select_row(this);
                    else
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().unselect_row(this);
                });
                box.pack_start(check_button, false, false, 5);
            }

            if(icon != null)
                box.pack_start(icon, false, false, 5);

            box.pack_start(title_label, false, true, 5);
            box.pack_end(size_label, false, true, 10);
            add(box);

            show_all();
            set_show_check_button(false);
        }

        public void set_show_check_button(bool show)
        {
            if(check_button != null)
            {
                check_button.set_visible(show);
                if(show == false)
                    check_button.set_active(false);
            }
        }

        public bool get_show_check_button()
        {
            if(check_button != null)
                return check_button.get_visible();
            else
                return false;
        }

        public void set_selected(bool selected)
        {
            if(check_button != null)
                check_button.set_active(selected);
        }

        public bool get_selected()
        {
             if(check_button == null)
                return false;
             else
                return check_button.get_active();
        }

        public Gdk.RGBA get_color()
        {
            return color;
        }

        public string get_item_name()
        {
            return item_name;
        }

        public string get_item_path()
        {
            return item_path;
        }

        public StorageItemType get_item_type()
        {
            return type;
        }

        public StorageItemType? get_parent_type()
        {
            return parent_type;
        }

        public void action_primary()
        {
            if(type == StorageItemType.FILE)
            {
                File file;
                if(parent_type == StorageItemType.TRASH || parent_type == StorageItemType.TRASHFILE || parent_type == StorageItemType.TRASHSUBFILE)
                    file = File.new_for_uri(item_path);
                else
                    file = File.new_for_path(item_path);

                try {
                    AppInfo.launch_default_for_uri(file.get_uri(), null);
                } catch (Error e) {
                	stderr.printf (e.message);
                }
            }
        }

        public void action_secondary()
        {
            bool show_popover = false;

            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (action_entries, this);

            var menu = new GLib.Menu ();
            var section = new GLib.Menu ();

            switch(type)
            {
                case StorageItemType.SYSTEM:
                case StorageItemType.AVAILABLE:
                case StorageItemType.STORAGE:
                case StorageItemType.TRASHSUBFILE:
                case StorageItemType.TRASHFILE:
                    break;
                case StorageItemType.USER:
                case StorageItemType.DOCUMENTS:
                case StorageItemType.DOWNLOADS:
                case StorageItemType.DESKTOP:
                case StorageItemType.MUSIC:
                case StorageItemType.PICTURES:
                case StorageItemType.VIDEOS:
                    section.append (_("Empty") + " " + item_name, "row.wipe-folder");
                    menu.append_section (null, section);
                    show_popover = true;
                    break;
                case StorageItemType.TRASH:
                    section.append (_("Empty Trash"), "row.wipe-trash");
                    menu.append_section (null, section);
                    show_popover = true;
                    break;
                case StorageItemType.DIRECTORY:
                case StorageItemType.FILE:
                    show_popover = true;
                    switch(parent_type)
                    {
                        case StorageItemType.TRASHFILE:
                            section.append (_("Restore"), "row.trash-restore");
                            menu.append_section (null, section);
                            section = new GLib.Menu ();
                            section.append (_("Delete from Trash"), "row.trash-delete");
                            menu.append_section (null, section);
                            break;
                        case StorageItemType.TRASHSUBFILE:
                            show_popover = false;
                            break;
                        default:
                            section.append (_("Rename"), "row.rename");
                            section.append (_("Move to"), "row.move");
                            menu.append_section (null, section);
                            section = new GLib.Menu ();
                            section.append (_("Move to Trash"), "row.move-to-trash");
                            section.append (_("Delete"), "row.delete");
                            menu.append_section (null, section);
                            break;
                    }
                    break;
            }

            if(show_popover)
            {
                var pop = new Gtk.Popover (this);
                pop.bind_model (menu, null);
                pop.insert_action_group ("row", action_group);
                pop.set_position(Gtk.PositionType.BOTTOM);
                pop.show_all ();
            }
        }

        private void action_trash_restore()
        {
            Timeout.add(0, () => {
                var storage_analyzer = StorageAnalyzer.get_default();
                storage_analyzer.restore_trash_file.begin(item_path, () => {
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                });

                return false;
            });
        }

        private void action_trash_delete()
        {
            Timeout.add(0, () => {
                var storage_analyzer = StorageAnalyzer.get_default();
                storage_analyzer.delete_trash_file.begin(item_path, () => {
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                });

                return false;
            });
        }

        private void action_wipe_folder()
        {
            var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Empty all items from %s?").printf(item_name));
            dialog.secondary_text = _("All items in the %s will be moved to the Trash.").printf(item_name);

            if(dialog.run() == Gtk.ResponseType.OK)
            {
            	Timeout.add(0, () => {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    storage_analyzer.wipe_folder.begin(item_path, () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                    });

                    return false;
                });
            }
            dialog.destroy();
        }

        private void action_wipe_trash()
        {
            var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Empty all items from Trash?"));
            dialog.secondary_text = _("All items in the Trash will be permanently deleted.");

            if(dialog.run() == Gtk.ResponseType.OK)
            {
            	Timeout.add(0, () => {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    storage_analyzer.wipe_trash.begin(() => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                    });

                    return false;
                });
            }
            dialog.destroy();
        }

        private void action_rename()
        {
            var pop = new Gtk.Popover (this);
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            box.margin = 10;
            var entry = new Gtk.Entry();
            entry.set_text (Path.get_basename(item_path));
            box.add(entry);
            var button = new Gtk.Button.with_label(_("Rename"));
            button.get_style_context().add_class ("suggested-action");
            button.clicked.connect (() => {
            	Timeout.add(0, () => {
                    string destination = Path.get_dirname(item_path) + "/" + entry.get_text();
                    var storage_analyzer = StorageAnalyzer.get_default();
                    storage_analyzer.move_file.begin(File.new_for_path(item_path), File.new_for_path(destination), () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                    });

                    return false;
                });
            });
            entry.activate.connect(() => {
                button.activate();
            });
            box.add(button);
            pop.add(box);
            pop.set_position(Gtk.PositionType.BOTTOM);
            pop.show_all ();
        }

        private void action_move()
        {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
                _("Select destination folder"), (GLib.Application.get_default() as Application).get_window(), Gtk.FileChooserAction.SELECT_FOLDER,
                _("Cancel"),
                Gtk.ResponseType.CANCEL,
                _("Select"),
                Gtk.ResponseType.ACCEPT);
            chooser.destroy_with_parent = true;
            Gtk.FileFilter filter = new Gtk.FileFilter();
            filter.add_custom(Gtk.FileFilterFlags.FILENAME, (filter_info) => {
                if(filter_info.filename != item_path)
                    return true;
                else
                    return false;
            });
            chooser.set_filter(filter);
            chooser.set_filename(item_path);
            chooser.show();

            if(chooser.run() == Gtk.ResponseType.ACCEPT)
            {
            	Timeout.add(0, () => {
            	    string destination = chooser.get_file().get_parse_name() + "/" + Path.get_basename(item_path);
                    var storage_analyzer = StorageAnalyzer.get_default();
                    storage_analyzer.move_file.begin(File.new_for_path(item_path), File.new_for_path(destination), () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                    });

                    return false;
                });
            }
            chooser.destroy ();
        }

        private void action_move_to_trash()
        {
            Timeout.add(0, () => {
                var storage_analyzer = StorageAnalyzer.get_default();
                storage_analyzer.trash_file.begin(item_path, () => {
                    ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                });

                return false;
            });
        }

        private void action_delete()
        {
            var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Are you sure you want to permanently delete %s?").printf(item_name));
            dialog.secondary_text = _("If you delete an item, it will be permanently lost.");

            if(dialog.run() == Gtk.ResponseType.OK)
            {
            	Timeout.add(0, () => {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    storage_analyzer.delete_file.begin(item_path, () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views.STORAGE]).get_storage_list_box().refresh();
                    });

                    return false;
                });
            }
            dialog.destroy();
        }
    }
}
