/* storage-actionbar.vala
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
	public class StorageActionBar : Gtk.ActionBar
	{
	    private Gtk.Button move_to_button;
	    private Gtk.Button delete_button;
	    private Gtk.Button move_to_trash_button;
	    private Gtk.Button empty_folder_button;
	    private Gtk.Button restore_button;
	    private Gtk.Button delete_from_trash_button;

        public StorageActionBar()
        {
            //common
            move_to_button = new Gtk.Button.with_label(_("Move to"));
            move_to_button.clicked.connect(move_to_clicked);
            delete_button = new Gtk.Button.with_label(_("Delete"));
            delete_button.clicked.connect(delete_clicked);
            delete_button.get_style_context().add_class ("destructive-action");
            move_to_trash_button = new Gtk.Button.with_label(_("Move to Trash"));
            move_to_trash_button.clicked.connect(move_to_trash_clicked);
            this.pack_start(move_to_button);
            this.pack_end(delete_button);
            this.pack_end(move_to_trash_button);

            //root
            empty_folder_button = new Gtk.Button.with_label(_("Empty folder"));
            empty_folder_button.clicked.connect(empty_folder_clicked);
            this.pack_end(empty_folder_button);

            //trash
            restore_button = new Gtk.Button.with_label(_("Restore"));
            restore_button.clicked.connect(restore_clicked);
            delete_from_trash_button = new Gtk.Button.with_label(_("Delete from Trash"));
            delete_from_trash_button.clicked.connect(delete_from_trash_clicked);
            delete_from_trash_button.get_style_context().add_class ("destructive-action");
            this.pack_start(restore_button);
            this.pack_end(delete_from_trash_button);

            hide_all();
        }

        public void show_common()
        {
            hide_all();
            move_to_button.visible = true;
            delete_button.visible = true;
            move_to_trash_button.visible = true;
        }

        public void show_root()
        {
            hide_all();
            empty_folder_button.visible = true;
        }

        public void show_trash()
        {
            hide_all();
            restore_button.visible = true;
            delete_from_trash_button.visible = true;
        }

        public void hide_all()
        {
            move_to_button.set_visible(false);
            delete_button.set_visible(false);
            move_to_trash_button.set_visible(false);
            empty_folder_button.set_visible(false);
            restore_button.set_visible(false);
            delete_from_trash_button.set_visible(false);
        }

        public void set_sensitive_all(bool sensitive)
        {
            move_to_button.set_sensitive(sensitive);
            delete_button.set_sensitive(sensitive);
            move_to_trash_button.set_sensitive(sensitive);
            empty_folder_button.set_sensitive(sensitive);
            restore_button.set_sensitive(sensitive);
            delete_from_trash_button.set_sensitive(sensitive);
        }

        private void move_to_clicked()
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
                foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                {
                    StorageRow storage_row = (StorageRow) row;
                    if(filter_info.filename == storage_row.get_item_path())
                        return false;
                }
                return true;
            });
            chooser.set_filter(filter);
            StorageRow storage_row = (StorageRow) ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_row();
            chooser.set_filename(storage_row.get_item_path());
            chooser.show();

            if(chooser.run() == Gtk.ResponseType.ACCEPT)
            {
            	Timeout.add(0, () => {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                    {
                        StorageRow actual_storage_row = (StorageRow) row;
                        string destination = chooser.get_file().get_parse_name() + "/" + Path.get_basename(actual_storage_row.get_item_path());
                        storage_analyzer.move_file.begin(File.new_for_path(actual_storage_row.get_item_path()), File.new_for_path(destination), () => {
                            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                        });
                    }
                    hide_selection_mode();

                    return false;
                });
            }
            chooser.destroy();
        }

        private void delete_clicked()
        {
            string files = "";
            foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
            {
                StorageRow storage_row = (StorageRow) row;
                if(files != "")
                    files += ", ";
                files += storage_row.get_item_name();
            }

            var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Are you sure you want to permanently delete this items %s?").printf(files));
            dialog.secondary_text = _("If you delete these items, they will be permanently lost.");

            if(dialog.run() == Gtk.ResponseType.OK)
            {
            	Timeout.add(0, () => {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                    {
                        StorageRow storage_row = (StorageRow) row;
                        storage_analyzer.delete_file.begin(storage_row.get_item_path(), () => {
                            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                        });
                    }
                    hide_selection_mode();

                    return false;
                });
            }
            dialog.destroy();


        }

        private void move_to_trash_clicked()
        {
            Timeout.add(0, () => {
                foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                {
                    var storage_analyzer = StorageAnalyzer.get_default();
                    StorageRow storage_row = (StorageRow) row;
                    storage_analyzer.trash_file.begin(storage_row.get_item_path(), () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                    });
                }
                hide_selection_mode();

                return false;
            });
        }

        private void empty_folder_clicked()
        {
            Timeout.add(0, () => {
                string folders = "";
                var storage_analyzer = StorageAnalyzer.get_default();
                foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                {
                    StorageRow storage_row = (StorageRow) row;
                    if(storage_row.get_item_type() == StorageItemType.TRASH)
                    {
                        var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                            Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Empty all items from Trash?"));
                        dialog.secondary_text = _("All items in the Trash will be permanently deleted.");

                        if(dialog.run() == Gtk.ResponseType.OK)
                        {
                            storage_analyzer.wipe_trash.begin(() => {
                                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                            });
                        }
                        dialog.destroy();
                    }
                    else
                    {
                        if(folders != "")
                            folders += ", ";
                        folders += storage_row.get_item_name();
                    }
                }

                if(folders != "")
                {
                    var dialog = new Gtk.MessageDialog ((GLib.Application.get_default() as Application).get_window(), Gtk.DialogFlags.MODAL,
                        Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, _("Empty all items from %s?").printf(folders));
                    dialog.secondary_text = _("All items in the %s will be moved to the Trash.").printf(folders);

                    if(dialog.run() == Gtk.ResponseType.OK)
                    {
                        foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                        {
                            StorageRow storage_row = (StorageRow) row;
                            storage_analyzer.wipe_folder.begin(storage_row.get_item_path(), () => {
                                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                            });
                        }

                    }
                    dialog.destroy();
                }
                hide_selection_mode();

                return false;
            });
        }

        private void restore_clicked()
        {
            Timeout.add(0, () => {
                var storage_analyzer = StorageAnalyzer.get_default();
                foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                {
                    StorageRow storage_row = (StorageRow) row;
                    storage_analyzer.restore_trash_file.begin(storage_row.get_item_path(), () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                    });
                }
                hide_selection_mode();

                return false;
            });
        }

        private void delete_from_trash_clicked()
        {
            Timeout.add(0, () => {
                var storage_analyzer = StorageAnalyzer.get_default();
                foreach (Gtk.ListBoxRow row in ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().get_selected_rows())
                {
                    StorageRow storage_row = (StorageRow) row;
                    storage_analyzer.delete_trash_file.begin(storage_row.get_item_path(), () => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[Views_list.STORAGE]).get_storage_list_box().refresh();
                    });
                }
                hide_selection_mode();

                return false;
            });
        }

        private void hide_selection_mode()
        {
            (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_selection_mode(false);
        }
	}
}
