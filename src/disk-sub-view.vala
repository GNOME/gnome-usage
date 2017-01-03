namespace Usage
{
    public class DiskSubView : View
    {
        public DiskSubView()
        {
            name = "DISK";
            var label = new Gtk.Label("What library we can use for disk I/O usage?");
            this.add(label);
        }
    }
}
