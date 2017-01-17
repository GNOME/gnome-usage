using Posix;
using Gee;

namespace Usage
{
    public class ProcessRow : Gtk.ListBoxRow
    {
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        SubProcessListBox sub_process_list_box;
        string display_name;
        static GLib.List<AppInfo> apps_info;
        ProcessListBoxType type;
        bool group;

        public Process process { get; private set; }
        public bool showing_details { get; private set; }
        public bool max_usage { get; private set; }

        public ProcessRow(Process process, ProcessListBoxType type, bool opened = false)
        {
            this.type = type;
            showing_details = opened;
            if(apps_info == null)
                apps_info = AppInfo.get_all(); //Because it takes too long
            this.process = process;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 0;
			var row_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			row_box.margin = 10;
        	load_label = new Gtk.Label(null);
        	load_label.ellipsize = Pango.EllipsizeMode.END;
        	load_label.max_width_chars = 30;

            Gtk.Image icon;
            load_icon_and_name(out icon, out display_name);
            var title_label = new Gtk.Label(display_name);
            row_box.pack_start(icon, false, false, 0);
            row_box.pack_start(title_label, false, true, 5);
            row_box.pack_end(load_label, false, true, 10);
            box.pack_start(row_box, false, true, 0);

            if(process.get_sub_processes() != null)
            {
                group = true;
                sub_process_list_box = new SubProcessListBox(process, type);
                revealer = new Gtk.Revealer();
                revealer.add(sub_process_list_box);
                box.pack_end(revealer, false, true, 0);

                if(opened)
                    show_details();
            }
            else
                group = false;

            update();

            this.add(box);
            show_all();

            if(opened && group)
                show_details();
        }

        private void load_icon_and_name(out Gtk.Image icon, out string display_name)
        {
            icon = null;
            AppInfo app_info = null;
        	foreach (AppInfo info in apps_info)
        	{
        	    string commandline = info.get_commandline();
        	    for (int i = 0; i < commandline.length; i++)
                {
                    if(commandline[i] == ' ' && commandline[i] == '%')
                        commandline = commandline.substring(0, i);
                }

                commandline = Path.get_basename(commandline);
                string process_full_cmd = process.get_cmdline() + " " + process.get_cmdline_parameter();
        	    if(commandline == process_full_cmd)
        	        app_info = info;
        	    else if(commandline.contains("google-" + process.get_cmdline() + "-")) //Fix for Google Chrome naming
                    app_info = info;

        	    if(app_info == null)
                {
                    commandline = info.get_commandline();
                    for (int i = 0; i < commandline.length; i++)
                    {
                        if(commandline[i] == ' ')
                            commandline = commandline.substring(0, i);
                    }

                    if(info.get_commandline().has_prefix(commandline + " " + commandline + "://")) //Fix for Steam naming
                        commandline = info.get_commandline();

                    commandline = Path.get_basename(commandline);
                    if(commandline == process.get_cmdline())
                        app_info = info;
                }
        	}

            if(app_info != null)
            {
                display_name = app_info.get_display_name();

        	    if(app_info.get_icon() != null)
                {
                    var icon_theme = new Gtk.IconTheme();
                    var icon_info = icon_theme.lookup_by_gicon_for_scale(app_info.get_icon(), 24, 1, Gtk.IconLookupFlags.FORCE_SIZE);
                    if(icon_info != null)
                    {
                        try
                        {
                            var pixbuf = icon_info.load_icon();
                            icon = new Gtk.Image.from_pixbuf(pixbuf);
                        }
                        catch(Error e) {
                            GLib.stderr.printf ("Could not load icon for application %s: %s\n", display_name, e.message);
                        }

                    }
                }
        	}
        	else
        	{
        	    display_name = process.get_cmdline();
        	}

        	if(icon == null)
        	{
        	    icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);
        	    icon.width_request = 24;
        	    icon.height_request = 24;
        	}

        	icon.margin_left = 10;
        	icon.margin_right = 10;

        }

        private void update()
        {
            CompareFunc<uint64?> sort = (a, b) => {
                return (int) ((uint64) (a < b) - (uint64) (a > b));
            };

            switch(type)
            {
                case ProcessListBoxType.PROCESSOR:
                    if(group)
                    {
                        string values_string = "";
                        var values = new GLib.List<uint64?>();
                        foreach(Process sub_process in process.get_sub_processes().get_values())
                            values.insert_sorted((uint64) sub_process.get_cpu_load(), sort);

                        foreach(uint64 value in values)
                            values_string += "   " + value.to_string() + " %";

                        load_label.set_label(values_string);
                    }
                    else
                        load_label.set_label(((int) process.get_cpu_load()).to_string() + " %");

                    if(process.get_cpu_load() >= 90)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
                case ProcessListBoxType.MEMORY:
                    if(group)
                    {
                        string values_string = "";
                        var values = new GLib.List<uint64?>();
                        foreach(Process sub_process in process.get_sub_processes().get_values())
                            values.insert_sorted(sub_process.get_mem_usage(), sort);

                        foreach(uint64 value in values)
                            values_string += "   " + Utils.format_size_values(value);

                        load_label.set_label(values_string);
                    }
                    else
                        load_label.set_label(Utils.format_size_values(process.get_mem_usage()));

                    if(process.get_mem_usage_percentages() >= 90)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
                case ProcessListBoxType.NETWORK:
                    if(group)
                    {
                        string values_string = "";
                        var values = new GLib.List<uint64?>();
                        foreach(Process sub_process in process.get_sub_processes().get_values())
                            values.insert_sorted((uint64) sub_process.get_net_all(), sort);

                         foreach(uint64 value in values)
                            values_string += "   " + Utils.format_size_values(value);

                        load_label.set_label(values_string);
                    }
                    else
                    {
                        load_label.set_label(Utils.format_size_values(process.get_net_all()));
                    }
                    break;
            }

            set_styles();
        }

        private void hide_details()
        {
            showing_details = false;
            revealer.set_reveal_child(false);
            load_label.visible = true;
            get_style_context().remove_class("opened");
        }

        private void show_details()
        {
            showing_details = true;
            revealer.set_reveal_child(true);
            load_label.visible = false;
            get_style_context().add_class("opened");
        }

        public new void activate()
        {
            if(group)
            {
                if(showing_details)
                    hide_details();
                else
                    show_details();

                set_styles();
            }
            else
            {
                var dialog = new ProcessDialog(process.get_pid(), display_name, process.get_cmdline());
                dialog.show_all();
            }
        }

        private void set_styles()
        {
            if(max_usage == true && showing_details == false)
                get_style_context().add_class("max");
            else
                get_style_context().remove_class("max");
        }
    }
}
