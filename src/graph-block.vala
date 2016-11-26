using Gtk;

namespace Usage
{
    public class GraphBlock : Gtk.Table
    {
        CookieGraph graph;
        GraphBlockRow application_row;
        GraphBlockRow others_row;
        GraphBlockRow available_row;
        Gdk.RGBA grey;
        Gdk.RGBA blue;
        Gdk.RGBA white;

        public GraphBlock(string name, string app_name)
        {
            Object(n_rows: 2, n_columns: 2, homogeneous: false);
            Gtk.AttachOptions flags = Gtk.AttachOptions.EXPAND;

            blue.parse("#4a90d9"); //TODO load from css
            grey.parse("#707070");
            white.parse("#fafafa");

            this.expand = true;
            var name_label = new Gtk.Label("<span font_desc=\"11.0\"><b>" + name + "</b></span>");
            name_label.set_use_markup(true);
            this.attach(name_label, 0, 1, 0, 1, flags, flags, 0, 0);

            graph = new CookieGraph(blue, grey, white);
            graph.height_request = 90;
            graph.width_request = 90;
            graph.margin = 15;
            this.attach(graph, 0, 1, 1, 2, flags, flags, 0, 0);

            application_row = new GraphBlockRow(app_name, blue);
            others_row = new GraphBlockRow(_("Others"), grey);
            available_row = new GraphBlockRow(_("Available"), white);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 15;
            box.pack_start(application_row);
            box.pack_start(others_row);
            box.pack_end(available_row);
            this.attach(box, 1, 2, 1, 2, flags, flags, 0, 0);
        }

        public void update(int application_percentages, int other_percentages)
        {
            graph.update(application_percentages, other_percentages);
            application_row.update(application_percentages);
            others_row.update(other_percentages);
            available_row.update(100-other_percentages);
        }
    }

    public class GraphBlockRow : Gtk.Box
    {
        Gtk.Label value_label;
        public GraphBlockRow(string label_text, Gdk.RGBA color)
        {
            Object(orientation: Gtk.Orientation.HORIZONTAL);
            this.spacing = 5;
            var color_rectangle = new ColorRectangle(color);
            var label = new Gtk.Label(label_text);
            label.margin = 5;
            value_label = new Gtk.Label("0 %");

            this.pack_start(color_rectangle, false, false);
            this.pack_start(label, false, true);
            this.pack_end(value_label, false, true);
        }

        public void update(int value)
        {
            value_label.set_text(value.to_string() + " %");
        }
    }

    public class ColorRectangle : Gtk.DrawingArea
    {
        public ColorRectangle(Gdk.RGBA color)
        {
            this.height_request = 17;
            this.width_request = 17;
            this.valign = Gtk.Align.CENTER;
            this.draw.connect ((context) =>
            {
            	int height = this.get_allocated_height ();
            	int width = this.get_allocated_width ();

                double degrees = Math.PI / 180.0;
                double x = 0;
                double y = 0;
                double radius = height / 5;

                context.new_sub_path();
                context.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
                context.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
                context.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
                context.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
                context.close_path();

                Gdk.cairo_set_source_rgba (context, color);
                context.fill();
            	return true;
            });
        }
    }
}
