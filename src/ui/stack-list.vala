/* stack-list.vala
 *
 * Copyright (C) 2023 Markus Göllnitz
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
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.StackList : Gtk.Box {
    private Gtk.ListBox list_box = new Gtk.ListBox ();
    private Queue<ListStore> models = new Queue<ListStore>();
    private int depth = 0;
    public Gtk.SelectionMode selection_mode {
        get { return list_box.selection_mode; }
        set { list_box.selection_mode = value; }
    }

    public void init (Gtk.ListBoxCreateWidgetFunc row_function) {
        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow ();

        scrolled_window.vexpand = true;
        scrolled_window.hexpand = true;
        scrolled_window.child = list_box;

        list_box.margin_top = 12;
        list_box.margin_bottom = 12;
        list_box.margin_start = 12;
        list_box.margin_end = 12;
        list_box.valign = Gtk.Align.START;
        list_box.add_css_class ("boxed-list");

        this.append (scrolled_window);

        list_box.row_activated.connect ((box, row) => {
            this.row_activated (row);
        });
        this.model_changed.connect ((model) => {
            list_box.bind_model (model, (item) => {
                return row_function (item);
            });
        });
    }

    public ListStore get_model () {
        return models.peek_head ();
    }

    public int get_depth () {
        return depth;
    }

    public void push_layer (ListStore model) {
        models.push_head (model);
        this.model_changed (model);
        depth += 1;
    }

    public bool layer_up () {
        ListStore previous_head = models.pop_head ();
        if (models.peek_head () != null) {
            this.model_changed (models.peek_head ());
        }
        depth -= 1;
        return previous_head != null;
    }

    public signal void model_changed (ListStore model);
    public signal void row_activated (Gtk.ListBoxRow row);
}
