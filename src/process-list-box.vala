/* process-list-box.vala
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

public delegate bool Usage.FilterFunc<T> (T object);
public delegate string Usage.LabelFactoryFunc<T> (T object);
public struct Usage.ProcessListBoxType {
    public CompareDataFunc<AppItem> comparator;
    public Usage.FilterFunc<AppItem> filter;
    public Usage.LabelFactoryFunc<AppItem> load_label_factory;
}

public class Usage.ProcessListBox : Adw.Bin {
    public Gtk.ListBox list_box { get; private set; default = new Gtk.ListBox (); }

    public bool empty { get; set; default = true; }
    public string search_text { get; set; default = ""; }

    private ListStore model;
    private ProcessListBoxType type;

    public ProcessListBox (ProcessListBoxType type) {
        this.set_child (list_box);

        list_box.set_selection_mode (Gtk.SelectionMode.NONE);
        list_box.add_css_class ("boxed-list");

        this.type = type;
        model = new ListStore (typeof (AppItem));
        list_box.bind_model (model, on_row_created);

        list_box.row_activated.connect ((row) => {
            var process_row = (ProcessRow) row;
            process_row.activate ();
        });

        this.notify["search-text"].connect ((sender, property) => {
            update ();
        });

        var system_monitor = SystemMonitor.get_default ();
        system_monitor.notify["process-list-ready"].connect (() => {
            if (system_monitor.process_list_ready)
                update ();
        });

        var settings = Settings.get_default ();
        Timeout.add (settings.list_update_interval_UI, update);

        bind_property ("empty", this, "visible", BindingFlags.INVERT_BOOLEAN);
    }

    private bool update () {
        model.remove_all ();

        var system_monitor = SystemMonitor.get_default ();
        Settings settings = Settings.get_default ();
        if (search_text == "") {
            foreach (unowned AppItem app in system_monitor.get_apps ()) {
                if (this.type.filter (app))
                    model.insert_sorted (app, this.type.comparator);
            }
        } else {
            foreach (unowned AppItem app in system_monitor.get_apps ()) {
                if (app.display_name.down ().contains (search_text.down ()) || app.representative_cmdline.down ().contains (search_text.down ()))
                    model.insert_sorted (app, this.type.comparator);
            }
        }

        empty = (model.get_n_items () == 0);
        return true;
    }

    private Gtk.Widget on_row_created (Object item) {
        return new ProcessRow ((AppItem) item, type);
    }
}
