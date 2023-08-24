/* speedometer.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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
 * Authors: Felipe Borges <felipeborges@gnome.org>
 */

using Gtk;

[GtkTemplate (ui = "/org/gnome/Usage/ui/speedometer.ui")]
public class Usage.Speedometer : Buildable, Adw.Bin {
    [GtkChild]
    private unowned Gtk.Box inner;

    [GtkChild]
    private unowned Gtk.Box content_area;

    private Gtk.CssProvider css_provider;

    private int _percentage = 0;
    public int percentage {
        get {
            return _percentage;
        }
        set {
            on_percentage_changed (value);

            _percentage = value;
        }
    }

    class construct {
        set_css_name ("Speedometer");
    }

    construct {
        css_provider = new Gtk.CssProvider ();
        inner.get_style_context ().add_provider (css_provider,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        bind_property ("width-request", content_area, "width-request", BindingFlags.BIDIRECTIONAL);
        bind_property ("height-request", content_area, "height-request", BindingFlags.BIDIRECTIONAL);
    }

    private void on_percentage_changed (int new_value) {
        if (new_value <= 0 && new_value >= 100)
            return;

        double new_angle = 90 + (360 * (new_value/100.0));
        var filling_color = "@view_bg_color";

        if (new_value > 50) {
            new_angle -= 180;
            filling_color = "@accent_bg_color";
        }

        var css =
        @".speedometer-inner {
            background: linear-gradient($(new_angle)deg, transparent 50%, $filling_color 50%),
                        linear-gradient(90deg, @view_bg_color 50%, transparent 50%);
        }";

        css_provider.load_from_string (css);
    }

    public void add_child (Builder builder, Object child, string? type) {
        /* This is a Vala bug. It will cause a "warning".
        (content_area as Buildable).add_child (builder, child, type);*/
        if (child is Gtk.Label) {
            content_area.append (child as Gtk.Widget);

            return;
        }

        base.add_child (builder, child, type);
    }
}
