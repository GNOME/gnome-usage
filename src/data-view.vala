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
    }
}
