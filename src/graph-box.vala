/* graph-box.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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

using Gtk;

public class Usage.GraphBox : Adw.Bin {

    class construct {
        set_css_name ("graph-box");
    }

    public GraphBox (GraphView graph) {
        this.add_css_class ("view");
        this.overflow = Gtk.Overflow.HIDDEN;
        graph.hexpand = true;
        graph.vexpand = true;
        this.child = graph;
    }
}
