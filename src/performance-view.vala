/* performance-view.vala
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

using Gtk;

[GtkTemplate (ui = "/org/gnome/Usage/ui/performance-view.ui")]
public class Usage.PerformanceView : View {
    [GtkChild]
    private unowned Gtk.Box switcher_box;

    [GtkChild]
    private unowned Gtk.Box performance_content;

    [GtkChild]
    private unowned Gtk.SearchBar search_bar;

    [GtkChild]
    private unowned Gtk.SearchEntry search_entry;

    [GtkChild]
    private unowned Gtk.ScrolledWindow scrolled_window;

    View[] sub_views;

    public PerformanceView () {
        name = "PERFORMANCE";
        title = _("Performance");
        icon_name = "speedometer-symbolic";

        sub_views = new View[] {
            new ProcessorSubView (),
            new MemorySubView ()
        };

        foreach (var sub_view in sub_views)
            performance_content.append (sub_view);

        AnimatedScrolledWindow animated_scrolled_window = new AnimatedScrolledWindow (scrolled_window);
        var stackSwitcher = new GraphStackSwitcher (animated_scrolled_window, sub_views);
        switcher_box.append (stackSwitcher);
    }

    [GtkCallback]
    private void on_search_entry_changed () {
        foreach (View sub_view in sub_views)
            ((SubView) sub_view).search_in_processes (search_entry.get_text ());
    }

    public void set_search_mode (bool enable) {
        search_bar.set_search_mode (enable);
        if (enable) {
            search_entry.grab_focus ();
        }
    }
}
