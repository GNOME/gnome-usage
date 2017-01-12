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

    }
}
