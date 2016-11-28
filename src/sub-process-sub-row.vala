using Posix;

namespace Usage
{
    public class SubProcessSubRow : Gtk.Box
    {
    	Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;
        Gtk.EventBox event_box;
        bool in_box = false;
        pid_t pid;
        int value;
        string cmdline;
        bool alive = true;

        //public bool is_headline { get; private set; }
        public bool max_usage { get; private set; }

        public SubProcessSubRow(pid_t pid, int value, string cmdline)
        {
            this.cmdline = cmdline;
            this.pid = pid;

            this.margin = 0;
            this.orientation = Gtk.Orientation.VERTICAL;
			var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			main_box.margin = 10;
        	title_label = new Gtk.Label(cmdline);
        	load_label = new Gtk.Label(null);
        	icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);

            main_box.pack_start(icon, false, false, 10);
            main_box.pack_start(title_label, false, true, 5);
            main_box.pack_end(load_label, false, true, 10);

            event_box = new Gtk.EventBox();
            event_box.add(main_box);

            event_box.button_press_event.connect ((event) => {
                var dialog = new ProcessDialog(pid, cmdline);
                dialog.show_all ();
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
            this.pack_end(separator, false, true, 0); //TODO Fix for last element

            set_value(value);

            show_all();
        }

        public string get_cmdline()
        {
            return cmdline;
        }

        public pid_t get_pid()
        {
            return pid;
        }

        public int get_value()
        {
            return value;
        }

        public bool get_alive()
        {
            return alive;
        }

        public bool set_alive(bool alive)
        {
            return this.alive = alive;
        }

        public void set_value(int value)
        {
            this.value = int.min(value, 100);
            alive = true;
        }

        public void update()
        {
            if(value >= 90)
                max_usage = true;
            else
                max_usage = false;

            load_label.set_label(value.to_string() + " %");
            style_css();
        }

        private void style_css()
        {
            event_box.get_style_context().remove_class("subProcessSubRow-max");
            event_box.get_style_context().remove_class("subProcessSubRow-max-hover");
            event_box.get_style_context().remove_class("subProcessSubRow");
            event_box.get_style_context().remove_class("subProcessSubRow-hover");

            if(max_usage)
            {
                if(in_box)
                    event_box.get_style_context().add_class("subProcessSubRow-max-hover");
                else
                    event_box.get_style_context().add_class("subProcessSubRow-max");
            }
            else
            {
                if(in_box)
                    event_box.get_style_context().add_class("subProcessSubRow-hover");
                else
                    event_box.get_style_context().add_class("subProcessSubRow");
            }
        }
    }
}
