namespace Usage
{
    public class ProcessRow : Gtk.Box
    {
		Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        Gtk.EventBox event_box;
        ProcessListBox sub_process_list_box; //TODO subprocess
        bool in_box = false;

        /*private Gee.ArrayList<String> names;
        private Gee.ArrayList<int> values;
        public Gee.ArrayList<uint> pids;*/
        private uint pid;
        private int value;
        string name;
        public bool alive = true;

        //public bool is_headline { get; private set; }
        public bool showing_details { get; private set; }
        public bool max_usage { get; private set; }

        public ProcessRow(/*Gee.ArrayList<uint> pids, Gee.ArrayList<int> values, Gee.ArrayList<int> values*/uint pid, int value, string name)
        {
            /*this.pids = pids;
            this.names = names;
            this.values = values;*/
            this.pid = pid;
            this.name = name;

            this.margin = 0;
            this.orientation = Gtk.Orientation.VERTICAL;
			var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			main_box.margin = 12;
        	title_label = new Gtk.Label(name);  //TODO implement give name
        	load_label = new Gtk.Label(null);
        	icon = new Gtk.Image.from_icon_name("dialog-error", Gtk.IconSize.BUTTON); //TODO implement give icon

            main_box.pack_start(icon, false, false, 10);
            main_box.pack_start(title_label, false, true, 5);
            main_box.pack_end(load_label, false, true, 10);

            sub_process_list_box = new ProcessListBox();
            for(int i = 4; i > 0; i--)
            {
                var row = new ProcessDetailListBoxRow("Title " + i.to_string(), 50); //TODO realy values
                sub_process_list_box.insert(row, 0);
            }

            revealer = new Gtk.Revealer();
            revealer.add(sub_process_list_box);

            event_box = new Gtk.EventBox();
            event_box.add(main_box);

            event_box.button_press_event.connect ((event) => {
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
            this.pack_end(separator, false, true, 0);// TODO Fix for last element

            set_value(value);
            show_all();
        }

        public uint get_pid()
        {
            return pid;
        }

        public int get_value()
        {
            return value;
        }

        public void set_value(int value)
        {
            this.value = int.min(value, 100);
            update();
        }

        private void update()
        {
            if(value >= 90)
                max_usage = true;
            else
                max_usage = false;

            load_label.set_label(value.to_string() + "%");

            style();
        }

        private void style()
        {
            if(max_usage)
            {
                 event_box.get_style_context().remove_class("processListBoxRow");
                 event_box.get_style_context().remove_class("processListBoxRow-hover");
                 event_box.get_style_context().remove_class("processListBoxRow-opened");

                if(showing_details)
                {
                    event_box.get_style_context().remove_class("processListBoxRow-max");
                    event_box.get_style_context().remove_class("processListBoxRow-max-hover");
                    event_box.get_style_context().add_class("processListBoxRow-max-opened");
                }
                else
                {
                    if(in_box)
                    {
                        event_box.get_style_context().remove_class("processListBoxRow-max-opened");
                        event_box.get_style_context().add_class("processListBoxRow-max-hover");
                    }
                    else
                    {
                        event_box.get_style_context().remove_class("processListBoxRow-max-hover");
                        event_box.get_style_context().add_class("processListBoxRow-max");
                    }
                }
            }
            else
            {
                event_box.get_style_context().remove_class("processListBoxRow-max");
                event_box.get_style_context().remove_class("processListBoxRow-max-hover");
                event_box.get_style_context().remove_class("processListBoxRow-max-opened");

                if(showing_details)
                {
                    event_box.get_style_context().remove_class("processListBoxRow");
                    event_box.get_style_context().remove_class("processListBoxRow-hover");
                    event_box.get_style_context().add_class("processListBoxRow-opened");
                }
                else
                {
                    if(in_box)
                    {
                        event_box.get_style_context().remove_class("processListBoxRow-opened");
                        event_box.get_style_context().add_class("processListBoxRow-hover");
                    }
                    else
                    {
                        event_box.get_style_context().remove_class("processListBoxRow-hover");
                        event_box.get_style_context().add_class("processListBoxRow");
                    }
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
