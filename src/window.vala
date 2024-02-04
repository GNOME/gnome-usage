/* window.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2020 Adrien Plazas <kekun.plazas@laposte.net>
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

public enum Usage.Views {
    CPU,
    MEMORY,
    STORAGE;
}

public enum Usage.HeaderBarMode {
    PERFORMANCE,
    STORAGE;
}

[GtkTemplate (ui = "/org/gnome/Usage/ui/window.ui")]
public class Usage.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Adw.ViewStack stack;

    [GtkChild]
    private unowned Gtk.Revealer performance_search_revealer;

    [GtkChild]
    private unowned Gtk.ToggleButton performance_search_button;

    [GtkChild]
    private unowned Gtk.SearchEntry search_entry;

    [GtkChild]
    private unowned Adw.ToolbarView content_area;

    private HeaderBarMode mode;

    private View[] views;

    public Window (Gtk.Application application) {
        GLib.Object (application : application);

        if (Config.PROFILE == "Devel") {
            this.add_css_class ("devel");
        }

        views = new View[] {
            new CpuView (),
            new MemoryView (),
            new StorageView (),
        };

        foreach (var view in views) {
            stack.add_titled_with_icon (view, view.name, view.title, view.icon_name);
        }

        this.search_entry.set_key_capture_widget (content_area);
    }

    public void set_mode (HeaderBarMode mode) {
        this.performance_search_button.active &= mode == HeaderBarMode.PERFORMANCE;
        this.performance_search_revealer.reveal_child = mode == HeaderBarMode.PERFORMANCE;

        SimpleAction performance_action = this.get_application ().lookup_action ("filter-processes") as SimpleAction;
        if (performance_action != null) {
            performance_action.set_enabled (mode == HeaderBarMode.PERFORMANCE);
        }

        this.mode = mode;
    }

    public void action_on_search () {
        switch (mode) {
            case HeaderBarMode.PERFORMANCE:
                performance_search_button.set_active (!performance_search_button.get_active ());
                break;
            case HeaderBarMode.STORAGE:
                break;
        }
    }

    public View[] get_views () {
        return views;
    }

    [GtkCallback]
    private void on_performance_search_button_toggled () {
        if (!this.performance_search_button.active) {
            this.search_entry.text = "";
        } else {
            search_entry.grab_focus ();
        }
    }

    [GtkCallback]
    private void on_search_entry_changed () {
        /* TODO: Implement a saner way of propagating search query. */
        ((CpuView) this.get_views ()[Views.CPU]).set_search_text (search_entry.get_text ());
        ((MemoryView) this.get_views ()[Views.MEMORY]).set_search_text (search_entry.get_text ());
    }

    [GtkCallback]
    private bool on_search_entry_key_pressed (uint keyvalue, uint keycode, Gdk.ModifierType state) {
        if (keyvalue == Gdk.Key.Down || keyvalue == Gdk.Key.KP_Down) {
            return this.child_focus (Gtk.DirectionType.TAB_FORWARD);
        }

        if (keyvalue == Gdk.Key.Escape) {
            this.performance_search_button.active = false;
        }

        return false;
    }

    [GtkCallback]
    private void on_visible_child_changed () {
        if (stack.visible_child_name == views[Views.STORAGE].name) {
            set_mode (HeaderBarMode.STORAGE);
        } else {
            set_mode (HeaderBarMode.PERFORMANCE);
        }
    }
}
