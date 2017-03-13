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
}
