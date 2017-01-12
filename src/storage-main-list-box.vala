using Gee;

namespace Usage
{
    public enum StoragemMainListBoxType
    {
        HOME,
        SYSTEM,
        ALL
    }

    public class StorageMainListBox : Gtk.ListBox
    {
        StoragemMainListBoxType type;

        public StorageMainListBox(StoragemMainListBoxType type)
        {
            this.type = type;
            set_selection_mode (Gtk.SelectionMode.NONE);
            update();
        }

        public void update()
        {
            switch(type)
            {
                case StoragemMainListBoxType.HOME:
                    create_home_rows(true);
                    break;
                case StoragemMainListBoxType.SYSTEM:
                    create_system_rows(true);
                    break;
                case StoragemMainListBoxType.ALL:
                    create_home_rows(false);
                    create_system_rows(true);
                    break;
            }
        }

        private void create_home_rows(bool show_available)
        {
            add(new StorageRow(StorageRowType.DOCUMENTS, "1.3 GB"));
            add(new StorageRow(StorageRowType.DOWNLOADS, "1.3 GB"));
            add(new StorageRow(StorageRowType.MUSIC, "1.3 GB"));
            add(new StorageRow(StorageRowType.PICTURES, "1.3 GB"));
            add(new StorageRow(StorageRowType.VIDEOS, "1.3 GB"));
            add(new StorageRow(StorageRowType.OTHERS, "1.3 GB"));
            add(new StorageRow(StorageRowType.TRASH, "1.3 GB"));
            add(new StorageRow(StorageRowType.CACHE, "1.3 GB"));
            add(new StorageRow(StorageRowType.USER, "1.3 GB", "Jan Hendricks"));
            if(show_available)
                add(new StorageRow(StorageRowType.AVAILABLE, "1.3 GB"));
        }

        private void create_system_rows(bool show_available)
        {
            add(new StorageRow(StorageRowType.SYSTEM, "2.1 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, "1.3 GB"));
            if(show_available)
                add(new StorageRow(StorageRowType.AVAILABLE, "1.3 GB"));
        }
    }
}
