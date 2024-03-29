/* storage-row-popover.vala
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

[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-row-popover.ui")]
public class Usage.StorageRowPopover : Gtk.Popover {

    [GtkChild]
    private unowned Gtk.Label label;

    public void popup_on_row (StorageViewRow row) {
        Graphene.Rect row_bounds = Graphene.Rect ();
        row.compute_bounds (this, out row_bounds);

        Gdk.Rectangle pointing_to = Gdk.Rectangle ();

        pointing_to.x = (int) row_bounds.get_top_left ().x;
        pointing_to.y = (int) row_bounds.get_top_left ().y;
        pointing_to.width = (int) row_bounds.get_width ();
        pointing_to.height = (int) row_bounds.get_height ();

        this.set_pointing_to (pointing_to);

        switch (row.item.custom_type) {
            case StorageViewType.OS:
                label.label = _("Operating system files are an essential part of your system and cannot be removed.");
                break;
            default:
                break;
        }

        popup ();
    }
}
