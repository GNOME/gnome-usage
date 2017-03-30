namespace Usage
{
    public class StorageView : View
    {
        private StorageListBox storage_list_box;

        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            storage_list_box = new StorageListBox();
            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(storage_list_box);

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            var graph = new StorageGraph();
            var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.position = 300;
            paned.add2(spinner);

            var center_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            var image = new Gtk.Image.from_icon_name("folder-symbolic", Gtk.IconSize.DIALOG );
            image.pixel_size = 128;
            center_box.add(image);

            Gtk.Label empty_label = new Gtk.Label("<span size='xx-large' font_weight='bold'>" + _("No content here") + "</span>");
            empty_label.set_use_markup (true);
            empty_label.margin_top = 10;
            center_box.add(empty_label);
            center_box.get_style_context().add_class("dim-label");
            var empty_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            empty_box.set_center_widget(center_box);
            empty_box.show_all();

            storage_list_box.loading.connect(() =>
            {
                paned.remove(empty_box);
                paned.remove(scrolled_window);
                paned.remove(graph);
                paned.add2(spinner);
            });

            storage_list_box.loaded.connect(() =>
            {
                paned.add1(scrolled_window);
                scrolled_window.show();

                paned.remove(spinner);
                paned.add2(graph);
                graph.show();
            });

            storage_list_box.empty.connect(() =>
            {
                paned.remove(scrolled_window);
                paned.remove(graph);
                paned.remove(spinner);
                paned.add2(empty_box);
                empty_label.show();
            });

            add(paned);
        }

        public StorageListBox get_storage_list_box()
        {
            return storage_list_box;
        }
    }
}
