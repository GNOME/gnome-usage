using Gtk;

namespace Usage {

    public class CookieGraph : Gtk.DrawingArea
    {
        int used_percentages = 0;
        int other_percentages = 0;

        public CookieGraph(Gdk.RGBA used_color, Gdk.RGBA others_color, Gdk.RGBA available)
        {
            this.draw.connect ((context) =>
            {
            	int height = this.get_allocated_height ();
            	int width = this.get_allocated_width ();

                double xc = width / 2.0;
                double yc = height / 2.0;
                double radius = int.min (width, height) / 2.0;
                double angle1 = - Math.PI / 2.0;
                double ratio;
                double angle2 = - Math.PI / 2.0;

                if(used_percentages > 0)
                {
                    angle1 = - Math.PI / 2.0;
                    ratio = (double) used_percentages / 100;
                    angle2 = ratio * 2 * Math.PI - Math.PI / 2.0;
                    context.move_to (xc, yc);
                    Gdk.cairo_set_source_rgba (context, used_color);
                    context.arc (xc, yc, radius, angle1, angle2);
                    context.fill();
                }

                if(other_percentages > 0)
                {
                    angle1 = angle2;
                    ratio = (double) other_percentages / 100;
                    angle2 = ratio * 2 * Math.PI - Math.PI / 2.0;
                    context.move_to (xc, yc);
                    Gdk.cairo_set_source_rgba (context, others_color);
                    context.arc (xc, yc, radius, angle1, angle2);
                    context.fill();
                }

                angle1 = angle2;
                angle2 = 2 * Math.PI - Math.PI / 2.0;
                context.move_to (xc, yc);
                Gdk.cairo_set_source_rgba (context, available);
                context.arc (xc, yc, radius, angle1, angle2);
                context.fill();
            	return true;
            });
        }

        public void update(int used_percentages, int other_percentages)
        {
            this.used_percentages = used_percentages;
            this.other_percentages = other_percentages;
            this.queue_draw();
        }
    }
}
