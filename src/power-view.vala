namespace Usage
{
    public class PowerView : View
    {
        public PowerView()
        {
            name = "POWER";
            title = _("Power");

            var label = new Gtk.Label("Page Power Content.");
            add(label);
        }
    }
}
