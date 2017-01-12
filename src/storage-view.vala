namespace Usage
{
    public class StorageView : View
    {
        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            var storage_list = new StorageList();
            var storage_graph = new StorageGraph();

            var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.add1(storage_list);
            paned.add2(storage_graph);
            add(paned);
        }
    }
}
