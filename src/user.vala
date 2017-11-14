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
        private Act.User _user;
        public uint uid { get { return _user.get_uid(); }}
        public string user_name { get { return _user.get_user_name(); }}
        public string real_name { get { return _user.get_real_name(); }}
        public bool is_local_account { get { return _user.is_local_account(); }}
        public bool is_logged_in {
            get {
                return user_name == GLib.Environment.get_user_name();
            }
        }
        public bool is_root {
            get {
                return uid == 0;
            }
        }

        public User(Act.User user)
        {
            this._user = user;
        }
    }
}
