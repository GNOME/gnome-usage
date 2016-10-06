namespace Usage
{
    public class PowerView : View
    {
        public PowerView()
        {
            name = "POWER";
            title = _("Power");

            var label1 = new Gtk.Label("Page Power Content.");
            add(label1);
        }

        public override void updateHeaderBar()
        {
            headerBar.clear();
            headerBar.showStackSwitcher();
        }
    }
}
