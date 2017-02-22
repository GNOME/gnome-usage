using Posix;
using Gee;

namespace Usage
{
    public class StorageRow : Gtk.ListBoxRow
    {
        private StorageItemType type;
        private string item_path;
        private string item_name;
        private Gdk.RGBA color;

        public StorageRow(StorageItem storage_item)
        {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 10;
            box.margin_top = 12;
            box.margin_bottom = 12;
            var size_label = new Gtk.Label(Utils.format_size_values(storage_item.get_size()));
            item_path = storage_item.get_path();
            item_name = storage_item.get_name();
            type = storage_item.get_item_type();

            string? color_css_class = null;
            bool is_header = false;

            ColorRectangle color_rectangle;

            switch(storage_item.get_item_type())
            {
                case StorageItemType.SYSTEM:
                    color_css_class = "system";
                    color_rectangle = new ColorRectangle.new_from_css(color_css_class);
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.TRASH:
                    color_css_class = "trash";
                    color_rectangle = new ColorRectangle.new_from_css(color_css_class);
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.USER:
                    color_css_class = "user";
                    color_rectangle = new ColorRectangle.new_from_css(color_css_class);
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.AVAILABLE:
                    color_css_class = "available-storage";
                    color_rectangle = new ColorRectangle.new_from_css(color_css_class);
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.STORAGE:
                    is_header = true;
                    box.margin_top = 9;
                    box.margin_bottom = 9;
                    break;
                case StorageItemType.DOCUMENTS:
                case StorageItemType.DOWNLOADS:
                case StorageItemType.DESKTOP:
                case StorageItemType.MUSIC:
                case StorageItemType.PICTURES:
                case StorageItemType.VIDEOS:
                    get_style_context().add_class("folders");
                    color = get_style_context().get_color(get_style_context().get_state());
                    get_style_context().remove_class("folders");
                    color_rectangle = new ColorRectangle.new_from_rgba(storage_item.get_color());
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.DIRECTORY:
                    color = storage_item.get_color();
                    var info = Gtk.IconTheme.get_default().lookup_icon("folder-symbolic", 15, 0);

                    try {
                        var pixbuf = info.load_symbolic (storage_item.get_color());
                        var icon = new Gtk.Image.from_pixbuf (pixbuf);
                        box.pack_start(icon, false, false, 5);
                    }
                    catch(Error e) {
                        GLib.stderr.printf ("Could not load folder-symbolic icon: %s\n", e.message);
                    }
                    break;
                 case StorageItemType.FILE:
                    color = storage_item.get_color();
                    var info = Gtk.IconTheme.get_default().lookup_icon("folder-documents-symbolic", 15, 0);

                    try {
                        var pixbuf = info.load_symbolic (storage_item.get_color());
                        var icon = new Gtk.Image.from_pixbuf (pixbuf);
                        box.pack_start(icon, false, false, 5);
                    }
                    catch(Error e) {
                        GLib.stderr.printf ("Could not load folder-documents-symbolic icon: %s\n", e.message);
                    }
                    break;
            }

            var title_label = new Gtk.Label(storage_item.get_name());
            title_label.set_ellipsize(Pango.EllipsizeMode.MIDDLE);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(size_label, false, true, 10);
            add(box);

            show_all();
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
    }
}
