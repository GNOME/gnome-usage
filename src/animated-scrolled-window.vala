using Gtk;

public class Usage.AnimatedScrolledWindow : Gtk.ScrolledWindow {
    public signal void scroll_changed(double y);
    private const uint DURATION = 400;

    construct {
        get_vadjustment().value_changed.connect(() => {
            scroll_changed(get_vadjustment().get_value());
        });
    }

    public void animated_scroll_vertically(int y) {
        var clock = get_frame_clock();
        int64 start_time = clock.get_frame_time();
        int64 end_time = start_time + 1000 * DURATION;
        double source = vadjustment.get_value();
        double target = y;
        ulong tick_id = 0;

        tick_id = clock.update.connect(() => {
            int64 now = clock.get_frame_time();

            if (!animate_step (now, start_time, end_time, source, target)) {
                clock.disconnect(tick_id);
                tick_id = 0;
                clock.end_updating();
            }
        });
        clock.begin_updating();
    }

    private bool animate_step (int64 now, int64 start_time, int64 end_time, double source, double target) {
        if (now < end_time) {
            double t = (now - start_time) / (double) (end_time - start_time);
            t = ease_out_cubic (t);
            vadjustment.set_value(source + t * (target - source));
            return true;
        } else {
            vadjustment.set_value(target);
            return false;
        }
    }

    private double ease_out_cubic (double t) {
        double p = t - 1;
        return p * p * p + 1;
    }
}
