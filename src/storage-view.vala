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

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
