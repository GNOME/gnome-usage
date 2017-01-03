namespace Usage
{
    public class StorageView : View
    {
        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            var label = new Gtk.Label("Page Storage Content.");
			add(label);
        }
    }
}
