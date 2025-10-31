/* user.vala
 *
 * Copyright (C) 2025 Markus Göllnitz
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

[DBus (name = "org.freedesktop.Accounts")]
public interface org.freedesktop.Accounts : Object {
    [DBus (name = "FindUserById")]
    public abstract string get_account_path_by_uid (int64 id) throws GLib.Error;

    [DBus (name = "org.freedesktop.Accounts.User")]
    public interface User : Object {
        [DBus (name = "SystemAccount")]
        public abstract bool system_account { get; }

        [DBus (name = "LocalAccount")]
        public abstract bool local_account { get; }

        [DBus (name = "AccountType")]
        public abstract int32 account_type { get; }

        [DBus (name = "RealName")]
        public abstract string real_name { owned get; }

        [DBus (name = "UserName")]
        public abstract string username { owned get; }

        [DBus (name = "Uid")]
        public abstract uint64 uid { get; }
    }
}

public class Usage.User : Object {
    public enum AccountType {
        STANDARD,
        ADMINISTRATOR,
        UNKNOWN;

        public static AccountType[] supported_types () {
            return new AccountType[] { AccountType.STANDARD, AccountType.ADMINISTRATOR };
        }
    }

    private static org.freedesktop.Accounts? accounts;

    class construct {
        try {
            accounts = Bus.get_proxy_sync (BusType.SYSTEM,
                                           "org.freedesktop.Accounts",
                                           "/org/freedesktop/Accounts");
        } catch (Error e) {
            critical ("Unable to obtain user account: %s", e.message);
        }
    }

    public uint64 uid { get; private set; }
    public string username {
        owned get {
            return this.user_account?.username ?? this.uid.to_string ();
        }
    }
    public string display_name {
        owned get {
            return this.user_account?.real_name ?? "";
        }
    }
    public bool is_local {
        get {
            bool is_local = this.user_account?.local_account ?? true;
            return is_local;
        }
    }
    public bool is_system_user {
        get {
            bool is_system_user = this.user_account?.system_account ?? false;
            return is_system_user;
        }
    }
    public AccountType account_type {
        get {
            AccountType account_type = (AccountType) this.user_account?.account_type;
            if (account_type in AccountType.supported_types ()) {
                account_type = AccountType.UNKNOWN;
            }
            return account_type;
        }
    }

    private org.freedesktop.Accounts.User? user_account;

    public User.from_uid (uint64 uid) {
        this.uid = uid;
        try {
            string? user_account_path = User.accounts?.get_account_path_by_uid ((int64) uid);
            if (user_account_path != null) {
                this.setup_user_account ((!) user_account_path);
                assert (this.uid == this.user_account?.uid);
            }
        } catch (Error e) {
            warning ("Unable to obtain user account: %s", e.message);
        }
    }

    public User.from_path (string user_account_path) {
        this.setup_user_account (user_account_path);
        this.uid = this.user_account?.uid ?? 1337;
    }

    private inline void setup_user_account (string user_account_path) {
        try {
            this.user_account = Bus.get_proxy_sync (BusType.SYSTEM,
                                                    "org.freedesktop.Accounts",
                                                    user_account_path);
        } catch (Error e) {
            warning ("Unable to obtain user account: %s", e.message);
        }
    }
}
