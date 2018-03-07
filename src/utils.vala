/* utils.vala
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

namespace Usage
{
    public class Utils
    {
        public static string format_size_values(uint64 value)
        {
            if(value >= 1000000000000)
                return "%.3f TB".printf((double) value / 1000000000000d);
            else if(value >= 1000000000)
                return "%.1f GB".printf((double) value / 1000000000d);
            else if(value >= 1000000)
                return(value / 1000000).to_string() + " MB";
            else if(value >= 1000)
                return (value / 1000).to_string() + " KB";
            else
                return value.to_string() + " B";
        }

        public static string format_size_speed_values(uint64 value)
        {
            if(value >= 1000000000000)
                return "%.3f TB/s".printf((double) value / 1000000000000d);
            else if(value >= 1000000000)
                return "%.1f GB/s".printf((double) value / 1000000000d);
            else if(value >= 1000000)
                return "%.2f MB/s".printf((double) value / 1000000d);
            else if(value >= 1000)
                return (value / 1000).to_string() + " KB/s";
            else
                return value.to_string() + " B/s";
        }

        public static Gdk.RGBA color_darker(Gdk.RGBA color, double percentage)
        {
            color.red = color_field_darker(color.red, percentage);
            color.green = color_field_darker(color.green, percentage);
            color.blue = color_field_darker(color.blue, percentage);

            return color;
        }

        public static Gdk.RGBA color_lighter(Gdk.RGBA color, double percentage)
        {
            color.red = color_field_lighter(color.red, percentage);
            color.green = color_field_lighter(color.green, percentage);
            color.blue = color_field_lighter(color.blue, percentage);

            return color;
        }

        private static double color_field_darker(double field, double percentage)
        {
            field = field * 255;
            return (field - ((field / 100) * percentage)) / 255;
        }

        private static double color_field_lighter(double field, double percentage)
        {
            field = field * 255;
            return (field + (((255 - field) / 100) * percentage)) / 255;
        }
    }

    public enum UserAccountType {
        STANDARD,
        ADMINISTRATOR,
    }

    [DBus (name = "org.freedesktop.Accounts")]
    public interface Fdo.Accounts : Object {
        public abstract async string FindUserById (int64 id) throws IOError;
    }

    [DBus (name = "org.freedesktop.Accounts.User")]
    public interface Fdo.AccountsUser : Object {
        public abstract bool SystemAccount { get; }
        public abstract bool LocalAccount { get; }
        public abstract int32 AccountType { get; }
        public abstract string RealName { owned get; }
        public abstract string UserName { owned get; }
        public abstract uint64 Uid { get; }
    }
}
