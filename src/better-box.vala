/* better-box.vala
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

namespace Usage {

    public class BetterBox : Gtk.Box
    {
        public int max_width_request { get; set;  default = -1; }

        private new void get_preferred_width(out int minimum_width, out int natural_width)
        {
            int min_width;
            int nat_width;
            get_preferred_width(out min_width, out nat_width);

            if (max_width_request > 0)
            {
                if (min_width > max_width_request)
                    min_width = max_width_request;

                if (nat_width > max_width_request)
                    nat_width = max_width_request;
            }
        }
    }
}
