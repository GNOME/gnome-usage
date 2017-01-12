using Gee;

namespace Usage
{
    public class StorageListBox : Gtk.ListBox
    {
        //ListStore model;

        public StorageListBox()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            //model = new ListStore();
            //width_request = 300; //TODO remove
            update();
        }

        public void update()
        {
            add(new StorageRow(StorageRowType.SYSTEM, _("Operting System"), "2.1 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Applications"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Documents"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Downloads"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Music"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Pictures"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Videos"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Other Files"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Trash"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Cache"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Videos"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("USER NAME"), "1.3 GB"));
            add(new StorageRow(StorageRowType.APPLICATIONS, _("Available"), "1.3 GB"));
            //model.remove_all();

            //model.insert_sorted(process, sort);
        }
    }
}
