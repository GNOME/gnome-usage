namespace Usage
{
    public class ProcessListBoxRow : Gtk.ListBoxRow
    {
		Gtk.Image icon;
        Gtk.Label title_label;
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        Gtk.EventBox event_box;
        ProcessListBox sub_process_list_box;

        public int sort_id;
        public bool is_headline { get; private set; }
        public bool showing_details { get; private set; }

        public ProcessListBoxRow(string title, int load)
        {
			var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var box_vertical = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			main_box.margin = 10;
        	title_label = new Gtk.Label(title);
        	load_label = new Gtk.Label(load.to_string() + " %");
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
                return true;
            });

            box_vertical.pack_start(event_box, false, true, 0);
            box_vertical.pack_end(revealer, false, true, 0);

            add(box_vertical);
            show_all();
        }

        private void hide_details()
        {
            showing_details = false;
            revealer.set_reveal_child(false);
        }

        private void show_details()
        {
            showing_details = true;
            revealer.set_reveal_child(true);
            //TODO change color of main_box
        }

        private void switch_details()
        {
            if(showing_details)
                hide_details();
            else
                show_details();
        }
    }

    public class ProcessListBox : Gtk.ListBox
    {
        public ProcessListBox()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
        {
        	if(before_row == null)
			    row.set_header(null);
            else
            {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
				separator.show();
				row.set_header(separator);
			}
        }
    }

    public class ProcessDetailListBoxRow : Gtk.ListBoxRow
    {
		private Gtk.Image icon;
        private Gtk.Label title_label;
        private Gtk.Label load_label;

        public int sort_id;

        public bool is_headline { get; private set; }

        public ProcessDetailListBoxRow(string title, int load)
        {
			var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.margin = 10;
        	title_label = new Gtk.Label(title);
        	load_label = new Gtk.Label(load.to_string() + " %");
        	icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);

            box.pack_start(icon, false, false, 10);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(load_label, false, true, 10);

            add(box);
            show_all();
        }
    }
}
