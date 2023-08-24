/* view.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

public abstract class Usage.View : Adw.Bin {
    public string title;
    public string icon_name;

    protected View () {
    }
}

public abstract class Usage.SubView : Adw.Bin {
    public string title;

    protected SubView () {
    }

    public abstract void search_in_processes (string text);
}
