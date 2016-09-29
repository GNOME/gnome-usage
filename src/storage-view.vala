namespace Usage {

    public class StorageView : View {

        public StorageView () {
            name = "STORAGE";
            title = _("Storage");

            var label1 = new Gtk.Label("Page 1 Content.");
			add(label1);
        }

        public override Gtk.Box? getMenuPopover() {
			return null;
        }
    }
}
