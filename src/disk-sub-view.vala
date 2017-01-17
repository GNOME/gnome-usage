namespace Usage
{
    public class DiskSubView : View
    {
        public DiskSubView()
        {
            name = "DISK";
            var label = new Gtk.Label("<span font_desc=\"14.0\">" + "What library we can use for disk I/O usage?" + "</span>");
            label.set_use_markup(true);
            label.get_style_context().add_class("dim-label");
            this.add(label);
        }
    }
}
