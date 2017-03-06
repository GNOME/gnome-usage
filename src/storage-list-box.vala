namespace Usage
{
    public class StorageListBox : Gtk.ListBox
    {
        public signal void loading();
        public signal void loaded();
        public signal void empty();

        private List<string?> path_history;
        private List<string?> name_history;
        private string? actual_path;
        private string? actual_name;
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

            path_history = new List<string>();
            name_history = new List<string>();
            actual_path = null;
            actual_name = null;
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
            actual_path = path.data;
            actual_name = name.data;
            load(path.data);
            path_history.delete_link(path);
            name_history.delete_link(name);
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
            }
        }

        public void reload()
        {
            this.hide();
            loading();
            storage_analyzer.cache_complete.connect(() => {
                storage_analyzer.prepare_items.begin(actual_path, color, (obj, res) => {
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

        private void load(string? path)
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
            storage_analyzer.prepare_items.begin(path, color, (obj, res) => {
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
            if(storage_row.get_item_type() == StorageItemType.FILE)
                ;//TODO: action on click
            else if(storage_row.get_item_type() != StorageItemType.STORAGE && storage_row.get_item_type() != StorageItemType.SYSTEM
                 && storage_row.get_item_type() != StorageItemType.AVAILABLE)
            {
                path_history.append(actual_path);
                name_history.append(actual_name);
                actual_path = storage_row.get_item_path();
                actual_name = storage_row.get_item_name();

                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_storage_back_button(true);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().set_title_text(actual_name);
                (GLib.Application.get_default() as Application).get_window().get_header_bar().show_title();

                if(root)
                    color = storage_row.get_color();

                load(actual_path);
            }
        }

        private Gtk.Widget on_row_created (Object item)
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
