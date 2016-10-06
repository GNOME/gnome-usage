namespace Usage
{
    public class StorageView : View
    {
        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            var label1 = new Gtk.Label("Page Storage Content.");
			add(label1);
        }

        public override void updateHeaderBar()
        {
            headerBar.clear();
            headerBar.showStackSwitcher();
        }
    }
}
