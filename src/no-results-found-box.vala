/* no-results-found-box.vala
 *
 * Copyright (C) 2017 Radhika Dua <radhikadua1997@gmail.com>
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
 */

namespace Usage
{
    public class NoResultsFoundBox : Gtk.Box
    {
        public NoResultsFoundBox()
        {
            orientation = Gtk.Orientation.VERTICAL;
            Gtk.Image no_process_image = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.DIALOG);

            Gtk.Label no_process_title = new Gtk.Label("<span font_desc=\"16.0\"><b>" + _("Couldn't find any results") + "</b></span>");
            no_process_title.set_use_markup(true);

            Gtk.Label no_process_hint = new Gtk.Label("<span font_desc=\"12.0\">" + _("You can try searching something else.") + "</span>");
            no_process_hint.set_use_markup(true);
            no_process_hint.get_style_context().add_class("dim-label");

            pack_start(no_process_image, false, false, 10);
            pack_start(no_process_title, false, false);
            pack_start(no_process_hint);
        }
    }
}
