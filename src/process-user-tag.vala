/* process-user-tag.vala
 *
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
 * Authors: Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.ProcessUserTag : Adw.Bin {
    private string _user_type = "default";
    public string user_type {
        get {
            return _user_type;
        }
        set {
            if (_user_type != null) {
                this.remove_css_class (_user_type);
            }
            _user_type = value;
            if (_user_type != null) {
                this.add_css_class (_user_type);
            }
        }
    }
    public virtual string label {
        get {
            return inner_label.label;
        }
        set {
            inner_label.label = value;
        }
    }

    private Gtk.Label inner_label;

    construct {
        this.inner_label = new Gtk.Label ("");
        this.child = inner_label;

        this.add_css_class ("tag");
    }
}
