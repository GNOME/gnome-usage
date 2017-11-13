/* user.vala
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
 * Authors: Lukasz Kolodziejczyk <lukasz.m.kolodziejczyk@gmail.com>
 */

namespace Usage
{
    public class User : Object
    {
        public uint? uid { get; private set; }
        public string? user_name { get; private set; }
        public string? real_name { get; private set; }
        public bool? is_local_account { get; private set; }
        public bool is_logged_in {
            get {
                return user_name != null && user_name == GLib.Environment.get_user_name();
            }
        }
        public bool is_available {
            get {
                return real_name != null;
            }
        }

        public User(uint? uid, string? user_name, string? real_name, bool? is_local_account)
        {
            this.uid = uid;
            this.user_name = user_name;
            this.real_name = real_name;
            this.is_local_account = is_local_account;
        }
    }
}
