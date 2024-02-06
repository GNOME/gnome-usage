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
public delegate Gtk.Widget Usage.WidgetFactoryFunc<T> (T object);
public struct Usage.ProcessListBoxType {
    public unowned CompareDataFunc<AppItem> comparator;
    public unowned Usage.FilterFunc<AppItem> filter;
    public unowned Usage.WidgetFactoryFunc<AppItem> load_widget_factory;
}

public class Usage.ProcessListBox : Adw.Bin {
    public Gtk.ListView list_view { get; private set; }

    public bool empty { get; set; default = true; }
    public string search_text { get; set; default = ""; }

    private ListStore model;
    private Gtk.Filter filter;
    private Gtk.Sorter sorter;
    private ProcessListBoxType type;
    private HashTable<AppItem, ProcessRowItem> item_for_app;

    public ProcessListBox (ProcessListBoxType type) {
        this.type = type;
        this.item_for_app = new HashTable<AppItem, ProcessRowItem> (GLib.direct_hash, GLib.direct_equal);
        this.model = new ListStore (typeof (ProcessRowItem));
        this.filter = new Gtk.CustomFilter ((item) => {
            AppItem app = ((ProcessRowItem) item).app;

            if (search_text != "") {
                return app.display_name.down ().contains (search_text.down ())
                       || app.representative_cmdline.down ().contains (search_text.down ())
                       || (app.container?.down ()?.contains (search_text.down ()) ?? false);
            }

            return this.type.filter (app);
        });
        this.sorter = new Gtk.CustomSorter((a, b) => {
            return this.type.comparator (((ProcessRowItem) a).app, ((ProcessRowItem) b).app);
        });

        Gtk.FilterListModel filter_model = new Gtk.FilterListModel (this.model, filter);
        Gtk.SortListModel sort_model = new Gtk.SortListModel (filter_model, sorter);
        Gtk.SelectionModel selection_model = new Gtk.NoSelection (sort_model);

        typeof (Usage.ProcessUserTag).ensure ();
        Gtk.BuilderListItemFactory factory = new Gtk.BuilderListItemFactory.from_resource (null, "/org/gnome/Usage/ui/process-row.ui");
        this.list_view = new Gtk.ListView (selection_model, factory);

        this.list_view.add_css_class ("card");
        this.list_view.show_separators = true;
        this.list_view.single_click_activate = true;

        this.list_view.activate.connect ((list_view, position) => {
            AppItem app = ((ProcessRowItem) list_view.get_model ().get_item (position)).app;

            if (app.representative_cmdline != "system") {
                AppDialog dialog = new AppDialog (app);
                dialog.present ((Gtk.Window) this.get_root ());
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
        var system_monitor = SystemMonitor.get_default ();
        List<unowned AppItem> apps = system_monitor.get_apps ();

        uint inserted = 0;
        uint removed = 0;

        for (uint position = 0; position < model.n_items; position++) {
            AppItem app = ((ProcessRowItem) model.get_item (position)).app;
            if (apps.index (app) < 0 || !app.is_running ()) {
                model.remove (position);
                item_for_app.remove (app);
                removed++;
            }
        }
        foreach (unowned AppItem app in system_monitor.get_apps ()) {
            uint index;
            if (!model.find (item_for_app.@get (app), out index) && app.is_running ()) {
                ProcessRowItem item = new ProcessRowItem (app, type);
                model.append (item);
                item_for_app.insert (app, item);
                inserted++;
            }
        }

        debug (@"$inserted started; $removed stopped");

        for (uint position = 0; position < model.n_items; position++) {
            ProcessRowItem item = (ProcessRowItem) model.get_item (position);
            item.notify_property ("load_widget");
        }
        filter.changed (Gtk.FilterChange.DIFFERENT);
        sorter.changed (Gtk.SorterChange.DIFFERENT);

        empty = (this.list_view.model.get_n_items () == 0);
        return true;
    }
}
