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

[GtkTemplate (ui = "/org/gnome/Usage/ui/memory-speedometer.ui")]
public class Usage.MemorySpeedometer : Adw.Bin {
    [GtkChild]
    private unowned Usage.Speedometer speedometer;

    [GtkChild]
    private unowned Gtk.Label label;

    [GtkChild]
    private unowned Gtk.Label ram_used;

    [GtkChild]
    private unowned Gtk.Label ram_available;

    private double ram_usage { get; set; }

    construct {
        var monitor = SystemMonitor.get_default ();
        Timeout.add_seconds (1, () => {
            var percentage = (((double) monitor.ram_usage / monitor.ram_total) * 100);

            this.speedometer.percentage = (int)percentage;
            label.label = "%d".printf ((int)percentage) + "%";

            var available = (monitor.ram_total - monitor.ram_usage);

            ram_used.label = Utils.format_size_values (monitor.ram_usage);
            ram_available.label = Utils.format_size_values (available);

            return true;
        });
    }
}
