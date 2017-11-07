/* memory-speedometer.vala
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
    public class MemorySpeedometer : Usage.Speedometer
    {
        private double ram_usage { get; set; }

        private Gtk.Label label;

        construct {
            label = new Gtk.Label("0.0");
            label.hexpand = true;
            label.use_markup = true;

            var monitor = SystemMonitor.get_default();
            Timeout.add_seconds(1, () => {
                ram_usage = (((double) monitor.ram_usage / monitor.ram_total) * 100);

                this.percentage = (int)ram_usage;
                label.set_markup("<span size='20000'>%d%</span>".printf(this.percentage));

                return true;
            });

            this.add_child(label);
        }        
    }
}
