/* utils.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
 * Copyright (C) 2023 Markus Göllnitz
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
 *          Markus Göllnitz <camelcasenick@bewares.it>
 */

public class Usage.Utils {
    public static string unescape (string escaped) {
        string unescaped = escaped;
        unichar c = 0;
        int index = 0;
        while (unescaped.get_next_char (ref index, out c)) {
            if (c != '\\') {
                continue;
            }
            unescaped.get_next_char (ref index, out c);
            if (c == 'x') {
                string char_point = unescaped.slice (index, index + 2);
                char unescaped_char = 0;
                for (int i = 0; i < char_point.length; i++) {
                    char offset = '0';
                    if (char_point.data[i] >= 'A') offset = 'A' - 10;
                    if (char_point.data[i] >= 'a') offset = 'a' - 10;
                    unescaped_char = unescaped_char * 16 + char_point.data[i] - offset;
                }
                unescaped = unescaped.splice (index - 2, index + 2, unescaped_char.to_string ());
            }
        }
        return unescaped.compress ();
    }

    public static string format_size_values (uint64 @value, out ulong? most_significant = null) {
        uint64 significant = @value;
        while (significant > 1000) {
            significant /= 1000;
        }
        most_significant = (ulong) significant;

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
        float step = 100 / (float) all_count;
        uint half_count = all_count / 2;

        if (order >= all_count)
            order = all_count - 1;

        if (order > (all_count / 2)) {
            float percentage = step * (order - half_count);
            if (reverse)
                return Utils.color_lighter (default_color, percentage);
            else
                return Utils.color_darker (default_color, percentage);
        } else {
            float percentage = step * (half_count - (order-1));
            if (reverse)
                return Utils.color_darker (default_color, percentage);
            else
                return Utils.color_lighter (default_color, percentage);
        }
    }

    public static Gdk.RGBA color_darker (Gdk.RGBA color, float percentage) {
        color.red = color_field_darker (color.red, percentage);
        color.green = color_field_darker (color.green, percentage);
        color.blue = color_field_darker (color.blue, percentage);

        return color;
    }

    public static Gdk.RGBA color_lighter (Gdk.RGBA color, float percentage) {
        color.red = color_field_lighter (color.red, percentage);
        color.green = color_field_lighter (color.green, percentage);
        color.blue = color_field_lighter (color.blue, percentage);

        return color;
    }

    private static float color_field_darker (float field, float percentage) {
        field = field * 255;
        return (field - ((field / 100) * percentage)) / 255;
    }

    private static float color_field_lighter (float field, float percentage) {
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
