using Gee;

namespace Usage
{
    public class StorageList : Gtk.Box
    {
        public StorageList()
        {
            orientation = Gtk.Orientation.VERTICAL;
            width_request = 300; //TODO remove

            var storage1 = create_header("Storage 1" , 650000000); //TODO find out one partiton or two (root and home)
            add(storage1);
            var storage_list_box = new StorageListBox();
            add(storage_list_box);
        }

        private Gtk.Box create_header(string storage_name, uint64 size)
        {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 10;
            var label_storage_name = new Gtk.Label(storage_name);
            var label_size = new Gtk.Label(Utils.format_size_values(size));
            box.pack_start(label_storage_name, false, false);
            box.pack_end(label_size, false, false);
            return box;
        }
    }
}
