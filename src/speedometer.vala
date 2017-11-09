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

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/speedometer.ui")]
    public class Speedometer : Buildable, Gtk.Bin
    {
        [GtkChild]
        private Gtk.Box content_area;

        private Gtk.CssProvider css_provider;

        private int _percentage;
        public int percentage {
            get {
                return _percentage;
            }
            set {
                

                on_percentage_changed(_percentage, value);

                _percentage = value;
            }
            default = 0; }

        construct {
            css_provider = new Gtk.CssProvider();
            Gtk.StyleContext.add_provider_for_screen(get_screen(),
                                                     css_provider,
                                                     Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        private void on_percentage_changed(int old_value, int new_value)
        {
            if (new_value <= 0 && new_value >= 100)
                return;

            double old_angle, new_angle;

            old_angle = 90 + (360 * (old_value/100.0));
            new_angle = 90 + (360 * (new_value/100.0));

            var css = """
                @keyframes speedometer_keyframes-%d {
            """.printf(new_value);

            if (new_value < 50)
            {
                css += """
                  from {
                    background: linear-gradient(%ddeg, transparent 50%, @theme_base_color 50%),
                                linear-gradient(90deg, @theme_base_color 50%, transparent 50%);
                  }
                  to {
                    background: linear-gradient(%ddeg, transparent 50%, @theme_base_color 50%),
                                linear-gradient(90deg, @theme_base_color 50%, transparent 50%);
                  }""".printf((int)old_angle, (int)new_angle);
            }
            else
            {
                css += """
                  from {
                    background: linear-gradient(%ddeg, transparent 50%, @theme_selected_bg_color 50%),
                                linear-gradient(90deg, @theme_base_color 50%, transparent 50%);
                  }
                  to {
                    background: linear-gradient(%ddeg, transparent 50%, @theme_selected_bg_color 50%),
                                linear-gradient(90deg, @theme_base_color 50%, transparent 50%);
                  }""".printf((int)old_angle-180, (int)new_angle-180);
            }

            css += """
            } .speedometer-inner { animation-name: speedometer_keyframes-%d; }
            """.printf(new_value);

            try
            {
                css_provider.load_from_data(css);
            }
            catch (GLib.Error error)
            {
                warning("Failed to animate speedometer: %s", error.message);
            }
        }

        public void add_child(Builder builder, Object child, string? type)
        {
            /* This is a Vala bug. It will cause a "warning".
            (content_area as Buildable).add_child(builder, child, type);*/
            if (child is Gtk.Label)
                content_area.add(child as Gtk.Widget);

            base.add_child(builder, child, type);
        }
    }
}
