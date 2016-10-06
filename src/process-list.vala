namespace Usage
{
    public class ProcessRow : Gtk.ListBoxRow
    {
		private Gtk.Image icon;
        private Gtk.Label title_label;
        private Gtk.Label load_label;

        public int sort_id;

        public bool is_headline { get; private set; }

        public ProcessRow(string title, int load)
        {
			var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.margin = 5;
        	title_label = new Gtk.Label(title);
        	load_label = new Gtk.Label(load.to_string() + " %");
        	icon = new Gtk.Image.from_icon_name("dialog-error", Gtk.IconSize.BUTTON);

            box.pack_start(icon, false, false, 10);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(load_label, false, true, 10);
            add(box);

            title_label.show();
            load_label.show();
            icon.show();
            box.show();
            show();
        }
    }

    public class ProcessList : Gtk.ListBox
    {
        public ProcessList()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
        }

        void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
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
}
