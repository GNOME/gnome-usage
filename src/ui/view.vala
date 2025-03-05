/* view.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023–2024 Markus Göllnitz
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

public abstract class Usage.View : Adw.BreakpointBin {
    public string title;
    public string icon_name;
    public Gtk.Widget? switcher_widget;
    public bool search_available = false;

    construct {
        this.width_request = 360;
        this.height_request = 210;
    }

    protected View () {
    }

    public virtual void set_search_text (string query) {
        if (search_available) {
            critical ("Search Feature Not Yet Implemented");
        }
    }

    public virtual bool prerequisite_fulfilled () {
        return true;
    }
}
