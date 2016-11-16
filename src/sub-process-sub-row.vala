namespace Usage
{
    //TODO rewrite as Row
    public class SubProcessSubRow : Gtk.ListBoxRow
    {
    	Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;

        uint pid;
        int value;
        string name;
        private bool alive = true;
        public bool max_usage { get; private set; }

        public SubProcessSubRow(uint pid, int value, string name)
        {
            this.name = name;
            this.pid = pid;
            set_can_focus(true);
            this.get_style_context().add_class("processDetailListBoxRow");
    		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    		box.margin = 12;
        	title_label = new Gtk.Label(name);
        	load_label = new Gtk.Label(value.to_string() + " %");
        	icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);

            box.pack_start(icon, false, false, 10);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(load_label, false, true, 10);

            set_value(value);

            add(box);
            show_all();
        }

        public string get_name()
        {
            return name;
        }

        public uint get_pid()
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
            update();
        }

        private void update()
        {
            if(value >= 90)
                max_usage = true;
            else
                max_usage = false;

            load_label.set_label(value.to_string() + "%");
        }
    }
}
