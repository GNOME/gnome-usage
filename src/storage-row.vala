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
        VIEOS,
        TRASH,
        OTHER,
        CACHE,
        USER,
        AVAIABLE
    }

    public class StorageRow : Gtk.ListBoxRow
    {
        StorageRowType type;

        public StorageRow(StorageRowType type, string title, string size)
        {
            this.type = type;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 10;
            var title_label = new Gtk.Label(title);
            var size_label = new Gtk.Label(size);

            //box.pack_start(icon, false, false, 0);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(size_label, false, true, 10);
            add(box);
        }
    }
}
