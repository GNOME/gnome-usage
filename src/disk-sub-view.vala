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

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
