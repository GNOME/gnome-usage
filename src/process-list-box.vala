/* process-list-box.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023-2024 Markus Göllnitz
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

public delegate bool Usage.FilterFunc<T> (T object);
public delegate string Usage.LabelFactoryFunc<T> (T object);
public struct Usage.ProcessListBoxType {
    public CompareDataFunc<AppItem> comparator;
    public Usage.FilterFunc<AppItem> filter;
    public Usage.LabelFactoryFunc<AppItem> load_label_factory;
}

public class Usage.ProcessListBox : Adw.Bin {
    public Gtk.ListView list_view { get; private set; }

    public bool empty { get; set; default = true; }
    public string search_text { get; set; default = ""; }

    private ListStore model;
    private ProcessListBoxType type;

    public ProcessListBox (ProcessListBoxType type) {
        this.type = type;
        this.model = new ListStore (typeof (ProcessRowItem));
        typeof (Usage.ProcessUserTag).ensure ();
        Gtk.BuilderListItemFactory factory = new Gtk.BuilderListItemFactory.from_resource (null, "/org/gnome/Usage/ui/process-row.ui");
        this.list_view = new Gtk.ListView (new Gtk.NoSelection (model), factory);

        this.list_view.add_css_class ("card");
        this.list_view.show_separators = true;
        this.list_view.single_click_activate = true;

        this.list_view.activate.connect ((list_view, position) => {
            AppItem app = (list_view.get_model ().get_item (position) as ProcessRowItem).app;

            if (app.is_killable ()) {
                var dialog = new QuitProcessDialog (app);
                dialog.set_transient_for ((Gtk.Window) this.get_root ());
                dialog.present ();
            }
        });

        this.set_child (list_view);

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

        this.bind_property ("empty", this, "visible", BindingFlags.INVERT_BOOLEAN | BindingFlags.SYNC_CREATE);
    }

    private bool update () {
        model.remove_all ();

        CompareDataFunc<ProcessRowItem> app_cmp = (a, b) => {
            return this.type.comparator (((ProcessRowItem) a).app, ((ProcessRowItem) b).app);
        };

        var system_monitor = SystemMonitor.get_default ();
        Settings settings = Settings.get_default ();
        if (search_text == "") {
            foreach (unowned AppItem app in system_monitor.get_apps ()) {
                if (this.type.filter (app))
                    model.insert_sorted (new ProcessRowItem (app, type), app_cmp);
            }
        } else {
            foreach (unowned AppItem app in system_monitor.get_apps ()) {
                if (app.display_name.down ().contains (search_text.down ()) || app.representative_cmdline.down ().contains (search_text.down ()))
                    model.insert_sorted (new ProcessRowItem (app, type), app_cmp);
            }
        }

        empty = (model.get_n_items () == 0);
        return true;
    }
}
