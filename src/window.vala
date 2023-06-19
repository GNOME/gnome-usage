/* window.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2020 Adrien Plazas <kekun.plazas@laposte.net>
 * Copyright (C) 2024 Markus Göllnitz
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

    private View[] views;

    public Window (Gtk.Application application) {
        GLib.Object (application : application);

        if (Config.PROFILE == "Devel") {
            this.add_css_class ("devel");
        }

        views = new View[] {
            new CpuView (),
            new MemoryView (),
            new NetworkView (),
            new StorageView (),
        };

        foreach (var view in views) {
            if (view.prerequisite_fulfilled ()) {
                stack.add_titled_with_icon (view, view.name, view.title, view.icon_name);
            }
        }

        this.search_entry.set_key_capture_widget (content_area);
    }

    public void action_on_search () {
        if (((View) this.stack.visible_child).search_available) {
            performance_search_button.set_active (!performance_search_button.get_active ());
        }
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
        foreach (View view in views) {
            view.set_search_text (search_entry.get_text ());
        }
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
        bool search_available = ((View) this.stack.visible_child).search_available;

        this.performance_search_button.active &= search_available;
        this.performance_search_revealer.reveal_child = search_available;

        SimpleAction performance_action = this.get_application ().lookup_action ("filter-processes") as SimpleAction;
        if (performance_action != null) {
            performance_action.set_enabled (search_available);
        }
    }

    [GtkCallback]
    string get_title_for_usage_view (Usage.View? view) {
        if (view != null) {
            return view.title;
        }
        return "";
    }

    /* TODO: use GtkCallback attribute, see https://gitlab.gnome.org/GNOME/vala/-/issues/1523 */
    static construct {
        bind_template_callback_full ("get_switcher_widget_for_usage_view", (Callback) get_switcher_widget_for_usage_view);
    }

    Gtk.Widget get_switcher_widget_for_usage_view (Usage.View? view) {
        Gtk.Widget? switcher_widget = null;
        string fallback_icon_name = "speedometer-symbolic";

        if (view != null) {
            switcher_widget = view.switcher_widget;
            fallback_icon_name = view.icon_name;
        }

        if (switcher_widget == null) {
            Gtk.Image fallback_icon = new Gtk.Image.from_icon_name (fallback_icon_name);
            fallback_icon.icon_size = Gtk.IconSize.LARGE;
            switcher_widget = fallback_icon;
        }

        return switcher_widget;
    }
}
