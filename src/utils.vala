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

public class Usage.Utils {
    public static string format_size_values (uint64 @value) {
        if (@value >= 1000)
            return GLib.format_size (@value);
        else
            return _("%llu B").printf (@value);
    }

    public static string format_size_speed_values (uint64 @value) {
        if (@value >= 1000)
            return _("%s/s").printf (GLib.format_size (@value));
        else
            return _("%llu B/s").printf (@value);
    }

    public static Gdk.RGBA generate_color (Gdk.RGBA default_color, uint order, uint all_count, bool reverse = false) {
        double step = 100 / (double) all_count;
        uint half_count = all_count / 2;

        if (order >= all_count)
            order = all_count - 1;

        if (order > (all_count / 2)) {
            double percentage = step * (order - half_count);
            if (reverse)
                return Utils.color_lighter (default_color, percentage);
            else
                return Utils.color_darker (default_color, percentage);
        } else {
            double percentage = step * (half_count - (order-1));
            if (reverse)
                return Utils.color_darker (default_color, percentage);
            else
                return Utils.color_lighter (default_color, percentage);
        }
    }

    public static Gdk.RGBA color_darker (Gdk.RGBA color, double percentage) {
        color.red = color_field_darker (color.red, percentage);
        color.green = color_field_darker (color.green, percentage);
        color.blue = color_field_darker (color.blue, percentage);

        return color;
    }

    public static Gdk.RGBA color_lighter (Gdk.RGBA color, double percentage) {
        color.red = color_field_lighter (color.red, percentage);
        color.green = color_field_lighter (color.green, percentage);
        color.blue = color_field_lighter (color.blue, percentage);

        return color;
    }

    private static double color_field_darker (double field, double percentage) {
        field = field * 255;
        return (field - ((field / 100) * percentage)) / 255;
    }

    private static double color_field_lighter (double field, double percentage) {
        field = field * 255;
        return (field + (((255 - field) / 100) * percentage)) / 255;
    }
}

public enum Usage.UserAccountType {
    STANDARD,
    ADMINISTRATOR;
}

[DBus (name = "org.freedesktop.Accounts")]
public interface Usage.Fdo.Accounts : Object {
    public abstract async string FindUserById (int64 id) throws GLib.Error;
}

[DBus (name = "org.freedesktop.Accounts.User")]
public interface Usage.Fdo.AccountsUser : Object {
    public abstract bool SystemAccount { get; }
    public abstract bool LocalAccount { get; }
    public abstract int32 AccountType { get; }
    public abstract string RealName { owned get; }
    public abstract string UserName { owned get; }
    public abstract uint64 Uid { get; }
}
