using Gtk;

namespace Usage {

    public class GraphBlockRow : Gtk.Box
    {
        Gtk.Label value_label;

        public GraphBlockRow(string label_text, string css_class)
        {
            Object(orientation: Gtk.Orientation.HORIZONTAL);
            var color_rectangle = new ColorRectangle(css_class);
            var label = new Gtk.Label(label_text);
            label.margin = 5;
            label.ellipsize = Pango.EllipsizeMode.END;
            label.max_width_chars = 15;
            value_label = new Gtk.Label("0 %");
            this.pack_start(color_rectangle, false, false);
            this.pack_start(label, false, true, 5);
            this.pack_end(value_label, false, true, 10);
        }

        public void update(int value)
        {
            value_label.set_text(value.to_string() + " %");
        }
    }
}
