/* animated-scrolled-window.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023 Markus Göllnitz
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Petr Štětka <pstetka@redhat.com>
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

using Gtk;

public class Usage.AnimatedScrolledWindow {
    private Gtk.Settings gtk_settings = Gtk.Settings.get_default ();

    public signal void scroll_changed (double y);
    private const uint DURATION = 400;
    public Gtk.ScrolledWindow scrolled_window { get; private set; }

    public AnimatedScrolledWindow (Gtk.ScrolledWindow scrolled_window) {
        this.scrolled_window = scrolled_window;
        scrolled_window.get_vadjustment ().value_changed.connect (() => {
            scroll_changed (scrolled_window.get_vadjustment ().get_value ());
        });
    }

    public void animated_scroll_vertically (int y) {
        if (!gtk_settings.gtk_enable_animations) {
            scrolled_window.vadjustment.set_value ((double) y);
            return;
        }

        var clock = scrolled_window.get_frame_clock ();
        int64 start_time = clock.get_frame_time ();
        int64 end_time = start_time + 1000 * DURATION;
        double source = scrolled_window.vadjustment.get_value ();
        double target = y;
        ulong tick_id = 0;

        tick_id = clock.update.connect (() => {
            int64 now = clock.get_frame_time ();

            if (!animate_step (now, start_time, end_time, source, target)) {
                clock.disconnect (tick_id);
                tick_id = 0;
                clock.end_updating ();
            }
        });
        clock.begin_updating ();
    }

    private bool animate_step (int64 now, int64 start_time, int64 end_time, double source, double target) {
        if (now < end_time) {
            double t = (now - start_time) / (double) (end_time - start_time);
            t = ease_out_cubic (t);
            scrolled_window.vadjustment.set_value (source + t * (target - source));
            return true;
        } else {
            scrolled_window.vadjustment.set_value (target);
            return false;
        }
    }

    private double ease_out_cubic (double t) {
        double p = t - 1;
        return p * p * p + 1;
    }
}
