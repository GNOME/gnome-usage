namespace Usage
{
    public class StorageView : View
    {
        public StorageView (Usage.HeaderBar headerBar)
        {
            base(headerBar);

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
