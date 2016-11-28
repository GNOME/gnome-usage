using Gtk;

namespace Usage {

    public class ColorRectangle : Gtk.DrawingArea
    {
        Gdk.RGBA color;
        class construct
        {
            set_css_name("CookieGraph");
        }

        public ColorRectangle(string css_class)
        {
            get_style_context().add_class(css_class);
            color = get_style_context().get_color(get_style_context().get_state());

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
