/* graph-stack-switcher.vala
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

public class Usage.GraphStackSwitcher : Gtk.Box {
    View[] sub_views;
    AnimatedScrolledWindow scrolled_window;

    GraphSwitcherButton[] buttons;

    class construct {
        set_css_name ("graph-stack-switcher");
    }

    public GraphStackSwitcher (AnimatedScrolledWindow scrolled_window, View[] sub_views) {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);

        this.sub_views = sub_views;
        this.scrolled_window = scrolled_window;

        scrolled_window.scroll_changed.connect (on_scroll_changed);

        buttons = {
            new GraphSwitcherButton.processor (_("Processor")),
            new GraphSwitcherButton.memory (_("Memory"))
        };

        buttons[0].set_active (true);

        foreach (GraphSwitcherButton button in buttons) {
            this.append (button);

            button.clicked.connect (() => {
                var button_number = get_button_number (button);
                scroll_to_view (button_number);
            });
        }
    }

    private int get_button_number (Gtk.Button button) {
        for (int i = 0; i < buttons.length; i++) {
            if (buttons[i] == button)
                return i;
        }

        return 0;
    }

    private void scroll_to_view (int button_number) {
        Graphene.Rect bounds;

        this.sub_views[button_number].compute_bounds (this.scrolled_window.scrolled_window, out bounds);
        scrolled_window.animated_scroll_vertically ((int) bounds.get_y () + (int) this.scrolled_window.scrolled_window.vadjustment.get_value ());
    }

    private void on_scroll_changed (double y) {
        Graphene.Rect bounds;

        var button_number = 0;
        for (int i = 1; i < buttons.length; i++) {
            this.sub_views[i].compute_bounds (this.scrolled_window.scrolled_window, out bounds);
            if (y < bounds.get_y () + this.scrolled_window.scrolled_window.vadjustment.get_value ())
                break;
            button_number = i;
        }

        buttons[button_number].set_active (true);
    }
}
