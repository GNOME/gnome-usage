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
        private static Act.UserManager user_manager;
        private static bool user_manager_available;

        private Act.User _user;

        public bool available { get; private set; }
        public uint uid { get; private set; }
        public string user_name { get { return _user.get_user_name(); }}
        public string real_name { get { return _user.get_real_name(); }}
        public bool is_local_account { get { return _user.is_local_account(); }}
        public bool is_loaded { get { return _user.is_loaded; }}
        public bool is_logged_in { get { return user_name == GLib.Environment.get_user_name(); }}
        public bool is_root { get { return uid == 0; }}

        class construct {
            user_manager = Act.UserManager.get_default();
            if(user_manager.is_loaded)
            {
                User.user_manager_available = true;
            }
            else
            {
                user_manager.notify["is-loaded"].connect(() => {
                    User.user_manager_available = true;
                });
            }
        }

        public User(uint uid)
        {
            this.uid = uid;

            if(user_manager_available)
            {
                _user = user_manager.get_user_by_id(uid);
                if(_user.is_loaded)
                {
                    available = true;
                }
                else
                {
                    _user.notify["is-loaded"].connect(() => {
                        available = true;
                    });
                }
            }
        }



    }
}
