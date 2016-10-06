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

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
