namespace Usage
{
    public class ProcessRow : Gtk.Box
    {
		Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        Gtk.EventBox event_box;
        SubProcessListBox sub_process_list_box;
        bool in_box = false;
        uint pid;
        int value;
        string name;
        bool alive = true;
        bool group = false;

        //public bool is_headline { get; private set; }
        public bool showing_details { get; private set; }
        public bool max_usage { get; private set; }

        public ProcessRow(uint pid, int value, string name)
        {
            this.pid = pid;
            this.name = name;

            this.margin = 0;
            this.orientation = Gtk.Orientation.VERTICAL;
			var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			main_box.margin = 12;
        	title_label = new Gtk.Label(name);  //TODO implement give name
        	load_label = new Gtk.Label(null);
        	load_label.ellipsize = Pango.EllipsizeMode.END;
        	load_label.max_width_chars = 30;
        	icon = new Gtk.Image.from_icon_name("dialog-error", Gtk.IconSize.BUTTON); //TODO implement give icon

            main_box.pack_start(icon, false, false, 10);
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
                return false;
            });

            event_box.enter_notify_event.connect ((event) => {
                in_box = true;
                style();
                return false;
            });

            event_box.leave_notify_event.connect ((event) => {
                in_box = false;
                style();
                return false;
            });

            var separator = new Gtk.Separator(Gtk.Orientation.VERTICAL);

            this.pack_start(event_box, false, true, 0);
            this.pack_end(revealer, false, true, 0);
            this.pack_end(separator, false, true, 0); //TODO Fix for last element

            set_value(pid, value);

            show_all();
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
                name = sub_process_list_box.get_first_name();
                pid = sub_process_list_box.get_first_pid();
                set_value(pid, sub_process_list_box.get_first_value());
                sub_process_list_box.remove_all();
                if(showing_details)
                    hide_details();
            }

            update();
        }

        public bool is_in_subrows(uint pid)
        {
            return sub_process_list_box.is_in_table(pid);
        }

        public void add_sub_row(uint pid, int value, string name)
        {
            alive = true;
            if(sub_process_list_box.get_sub_rows_count() == 0)
            {
                sub_process_list_box.add_sub_row(this.pid, this.value, this.name);
                group = true;
            }

            sub_process_list_box.add_sub_row(pid, value, name);
        }

        public void update_sub_row(uint pid, int value)
        {
            alive = true;
            sub_process_list_box.update_sub_row(pid, value);
        }

        public string get_name()
        {
            return name;
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

        public void set_value(uint pid, int value)//TODO rename to set_value?
        {
            alive = true;
            if(!group)
                this.value = int.min(value, 100);
            else
            {
                if(sub_process_list_box.is_in_table(pid))
                    sub_process_list_box.update_sub_row(pid, value);
                else
                    sub_process_list_box.add_sub_row(pid, value, this.name);
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

            style();
        }

        private void style()
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
            style();
        }

        private void show_details()
        {
            showing_details = true;
            revealer.set_reveal_child(true);
            load_label.visible = false;
            style();
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
