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
            var title_label = new Gtk.Label(storage_item.get_name());
            title_label.set_ellipsize(Pango.EllipsizeMode.MIDDLE);

            switch(storage_item.get_item_type())
            {
                case StorageItemType.SYSTEM:
                    var color_rectangle = new ColorRectangle.new_from_css("system");
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.TRASH:
                    var color_rectangle = new ColorRectangle.new_from_css("trash");
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.USER:
                    var color_rectangle = new ColorRectangle.new_from_css("user");
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.AVAILABLE:
                    var color_rectangle = new ColorRectangle.new_from_css("available-storage");
                    color = color_rectangle.get_color();
                    box.pack_start(color_rectangle, false, false, 5);
                    break;
                case StorageItemType.STORAGE:
                    box.margin_top = 10;
                    box.margin_bottom = 10;
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
                    get_style_context().add_class("folders");
                    color = get_style_context().get_color(get_style_context().get_state());
                    get_style_context().remove_class("folders");
                    var color_rectangle = new ColorRectangle.new_from_rgba(storage_item.get_color());
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
