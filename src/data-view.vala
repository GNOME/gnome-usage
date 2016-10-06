namespace Usage
{
    public class DataView : View
    {
        public DataView ()
        {
            name = ("DATA");
            title = _("Data");

            var label1 = new Gtk.Label("Page Data Content.");
      		add(label1);
        }

        public override void updateHeaderBar()
        {
             headerBar.clear();
             headerBar.showStackSwitcher();
        }
    }
}
