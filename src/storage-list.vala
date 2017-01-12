using Gee;

namespace Usage
{
    public class StorageList : Gtk.Stack
    {
        Gtk.Box main_page;
        public StorageList()
        {
            main_page = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            //width_request = 300; //TODO remove

            var storage1 = create_header("Storage 1" , 650000000); //TODO find out one partiton or two (root and home)
            main_page.add(storage1);
            var storage_list_box1 = new StorageListBox();
            main_page.add(storage_list_box1);
            var storage2 = create_header("Storage 2" , 650000000); //TODO find out one partiton or two (root and home)
            main_page.add(storage2);
            var storage_list_box2 = new StorageListBox();
            main_page.add(storage_list_box2);

            add_named(main_page, "MAIN_PAGE");

        }

        private Gtk.Box create_header(string storage_name, uint64 size)
        {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin_top = 10;
            box.margin_bottom = 10;
            box.margin_start = 20;
            box.margin_end = 20;
            var label_storage_name = new Gtk.Label(storage_name);
            var label_size = new Gtk.Label(Utils.format_size_values(size));
            box.pack_start(label_storage_name, false, false);
            box.pack_end(label_size, false, false);
            return box;
        }
    }
}
