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

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(storage_list);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.width_request = 300;

            var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.add1(scrolled_window);
            paned.add2(storage_graph);
            add(paned);
        }
    }
}
