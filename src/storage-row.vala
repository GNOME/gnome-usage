using Posix;
using Gee;

namespace Usage
{
    public enum StorageRowType
    {
        SYSTEM,
        APPLICATIONS,
        DOCUMENTS,
        DOWNLOADS,
        MUSIC,
        PICTURES,
        VIDEOS,
        TRASH,
        OTHERS,
        CACHE,
        USER,
        AVAILABLE
    }

    public class StorageRow : Gtk.ListBoxRow
    {
        StorageRowType type;

        public StorageRow(StorageRowType type, string size , string? user_name = null)
        {
            this.type = type;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 10;
            var size_label = new Gtk.Label(size);

            string title;
            string color_css_class;

            switch(type)
            {
                default:
                case StorageRowType.SYSTEM:
                    title = _("Operting System");
                    color_css_class = "system";
                    break;
                case StorageRowType.APPLICATIONS:
                    title = _("Applications");
                    color_css_class = "applications";
                    break;
                case StorageRowType.DOCUMENTS:
                    title = _("Documents");
                    color_css_class = "documents";
                    break;
                case StorageRowType.DOWNLOADS:
                    title = _("Downloads");
                    color_css_class = "downloads";
                    break;
                case StorageRowType.MUSIC:
                    title = _("Music");
                    color_css_class = "music";
                    break;
                case StorageRowType.PICTURES:
                    title = _("Pictures");
                    color_css_class = "pictures";
                    break;
                case StorageRowType.VIDEOS:
                    title = _("Videos");
                    color_css_class = "videos";
                    break;
                case StorageRowType.TRASH:
                    title = _("Trash");
                    color_css_class = "trash";
                    break;
                case StorageRowType.OTHERS:
                    title = _("Other Files");
                    color_css_class = "others-storage";
                    break;
                case StorageRowType.CACHE:
                    title = _("Cache");
                    color_css_class = "cache";
                    break;
                case StorageRowType.USER:
                    title = user_name;
                    color_css_class = "user";
                    break;
                case StorageRowType.AVAILABLE:
                    title = _("Available");
                    color_css_class = "available-storage";
                    break;
            }

            var title_label = new Gtk.Label(title);
            var color_rectangle = new ColorRectangle(color_css_class);

            box.pack_start(color_rectangle, false, false, 5);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(size_label, false, true, 10);
            add(box);
        }
    }
}
