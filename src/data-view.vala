namespace Usage
{
    public class DataView : View
    {
        public DataView ()
        {
            name = ("DATA");
            title = _("Data");

            var label = new Gtk.Label("Page Data Content.");
      		add(label);
        }

        public override void update_header_bar()
        {
             header_bar.clear();
             header_bar.show_stack_switcher();
        }
    }
}
