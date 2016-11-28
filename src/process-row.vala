using Posix;

namespace Usage
{
    public class ProcessRow : Gtk.Box //TODO use Row
    {
		Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        Gtk.EventBox event_box;
        SubProcessListBox sub_process_list_box;
        bool in_box = false;
        pid_t pid;
        int value;
        string cmdline;
        string display_name;
        bool alive = true;
        bool group = false;

        //public bool is_headline { get; private set; }
        public bool showing_details { get; private set; }
        public bool max_usage { get; private set; }

        public ProcessRow(pid_t pid, int value, string cmdline)
        {
            this.pid = pid;
            this.cmdline = cmdline;

            this.margin = 0;
            this.orientation = Gtk.Orientation.VERTICAL;
			var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			main_box.margin = 10;
        	load_label = new Gtk.Label(null);
        	load_label.ellipsize = Pango.EllipsizeMode.END;
        	load_label.max_width_chars = 30;

            load_icon_and_name();
            main_box.pack_start(icon, false, false, 0);
            main_box.pack_start(title_label, false, true, 5);
            main_box.pack_end(load_label, false, true, 10);

            sub_process_list_box = new SubProcessListBox();

            revealer = new Gtk.Revealer();
            revealer.add(sub_process_list_box);

            event_box = new Gtk.EventBox();
            event_box.add(main_box);

            event_box.button_press_event.connect ((event) => {
                if(group)
                    switch_details();
                else
                {
                    var dialog = new ProcessDialog(pid, display_name);
                    dialog.show_all ();
                }

                return false;
            });

            event_box.enter_notify_event.connect ((event) => {
                in_box = true;
                style_css();
                return false;
            });

            event_box.leave_notify_event.connect ((event) => {
                in_box = false;
                style_css();
                return false;
            });

            var separator = new Gtk.Separator(Gtk.Orientation.VERTICAL);

            this.pack_start(event_box, false, true, 0);
            this.pack_end(revealer, false, true, 0);
            this.pack_end(separator, false, true, 0); //TODO Fix for last element

            set_value(pid, value);

            show_all();
        }

        public void load_icon_and_name()
        {
            AppInfo app_info = null;
        	var apps_info = AppInfo.get_all();
        	foreach (AppInfo info in apps_info)
        	{
        	    string commandline = info.get_commandline();
        	    for (int i = 0; i < commandline.length; i++)
                {
                    if(commandline[i] == ' ')
                        commandline = commandline.substring(0, i);
                }
                commandline = Path.get_basename(commandline);

        	    if(commandline == cmdline)
        	        app_info = info;
        	}

            bool not_have_icon = false;
            if(app_info != null)
            {
                display_name = app_info.get_display_name();
        	    title_label = new Gtk.Label(display_name);

        	    if(app_info.get_icon() == null)
                    not_have_icon = true;
                else
                {
                    var icon_theme = new Gtk.IconTheme();
                    var icon_info = icon_theme.lookup_by_gicon_for_scale(app_info.get_icon(), 24, 1, Gtk.IconLookupFlags.FORCE_SIZE);
                    if(icon_info != null)
                    {
                        var pixbuf = icon_info.load_icon();
                        icon = new Gtk.Image.from_pixbuf(pixbuf);
                    }
                    else
                        not_have_icon = true;
                }
        	}
        	else
        	{
        	    display_name = cmdline;
        	    title_label = new Gtk.Label(display_name);
        	    not_have_icon = true;
        	}

        	if(not_have_icon)
        	{
        	    icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);
        	    icon.width_request = 24;
        	    icon.height_request = 24;
        	}

        	icon.margin_left = 10;
        	icon.margin_right = 10;

        }

        public void pre_update()
        {
            alive = false;
            sub_process_list_box.pre_update();
        }

        public void post_update()
        {
            sub_process_list_box.post_update();

            if(sub_process_list_box.get_sub_rows_count() == 1)
            {
                group = false;
                cmdline = sub_process_list_box.get_first_cmdline();
                pid = sub_process_list_box.get_first_pid();
                set_value(pid, sub_process_list_box.get_first_value());
                sub_process_list_box.remove_all();
                if(showing_details)
                    hide_details();
            }

            update();
        }

        public bool is_in_subrows(pid_t pid)
        {
            return sub_process_list_box.is_in_table(pid);
        }

        public void add_sub_row(pid_t pid, int value, string cmdline)
        {
            alive = true;
            if(sub_process_list_box.get_sub_rows_count() == 0)
            {
                sub_process_list_box.add_sub_row(this.pid, this.value, this.cmdline);
                group = true;
            }
            sub_process_list_box.add_sub_row(pid, value, cmdline);
        }

        public void update_sub_row(pid_t pid, int value)
        {
            alive = true;
            sub_process_list_box.update_sub_row(pid, value);
        }

        public string get_cmdline()
        {
            return cmdline;
        }

        public bool get_alive()
        {
            return alive;
        }

        public uint get_pid()
        {
            return pid;
        }

        public int get_value()
        {
            return value;
        }

        public void set_value(pid_t pid, int value)
        {
            alive = true;
            if(sub_process_list_box.is_in_table(pid))
                sub_process_list_box.update_sub_row(pid, value);
            else
                if(group)
                   sub_process_list_box.add_sub_row(pid, value, cmdline);
                else
                {
                    if(pid == this.pid)
                        this.value = int.min(value, 100);
                    else
                    {
                        this.pid = pid;
                        this.value = int.min(value, 100);
                    }

                }
        }

        private void update()
        {
            if(group)
            {
                int max_value = 0;
                string values = "";
                foreach(int sub_value in sub_process_list_box.get_values())
                {
                    values += "   " + sub_value.to_string() + " %";
                    
                    if(sub_value > max_value)
                        max_value = sub_value;
                }
                this.value = max_value;

                load_label.set_label(values);
            }
            else
                load_label.set_label(value.to_string() + " %");

             if(value >= 90)
                 max_usage = true;
             else
                 max_usage = false;

            style_css();
        }

        private void style_css()
        {
            event_box.get_style_context().remove_class("processRow-max");
            event_box.get_style_context().remove_class("processRow-max-hover");
            event_box.get_style_context().remove_class("processRow");
            event_box.get_style_context().remove_class("processRow-hover");
            event_box.get_style_context().remove_class("processRow-opened");

            if(showing_details)
                event_box.get_style_context().add_class("processRow-opened");
            else
            {
                if(max_usage)
                {
                    if(in_box)
                        event_box.get_style_context().add_class("processRow-max-hover");
                    else
                        event_box.get_style_context().add_class("processRow-max");
                }
                else
                {
                    if(in_box)
                        event_box.get_style_context().add_class("processRow-hover");
                    else
                        event_box.get_style_context().add_class("processRow");
                }
            }
        }

        private void hide_details()
        {
            showing_details = false;
            revealer.set_reveal_child(false);
            load_label.visible = true;
            style_css();
        }

        private void show_details()
        {
            showing_details = true;
            revealer.set_reveal_child(true);
            load_label.visible = false;
            style_css();
        }

        private void switch_details()
        {
            if(showing_details)
                hide_details();
            else
                show_details();
        }
    }
}
