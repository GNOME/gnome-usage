namespace Usage
{
    public class DiskSubView : View, SubView
    {
        public DiskSubView()
        {
            name = "DISK";
            var label = new Gtk.Label("<span font_desc=\"14.0\">" + "What library we can use for disk I/O usage?" + "</span>");
            label.set_use_markup(true);
            label.get_style_context().add_class("dim-label");
            this.add(label);
        }

        public void search_in_processes(string text)
        {

        }
    }
}
