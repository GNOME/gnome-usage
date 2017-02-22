namespace Usage
{
    public class StorageView : View
    {
        private StorageListBox storage_list_box;

        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.get_style_context().add_class("storage");
            storage_list_box = new StorageListBox();
            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(box);

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            box.pack_start(spinner, true, true, 0);
            box.pack_start(storage_list_box, false, false, 0);

            storage_list_box.loading.connect(() =>
            {
                spinner.show();
            });

            storage_list_box.loaded.connect(() =>
            {
                spinner.hide();
            });

            var graph = new StorageGraph();

            var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.position = 300;
            paned.add1(scrolled_window);
            paned.add(graph);
            add(paned);
        }

        public StorageListBox get_storage_list_box()
        {
            return storage_list_box;
        }
    }
}
