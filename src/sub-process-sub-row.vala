using Posix;

namespace Usage
{
    public class SubProcessSubRow : Gtk.ListBoxRow
    {
        Gtk.Label load_label;
        public Process process { get; private set; }
        public bool max_usage { get; private set; }

        public SubProcessSubRow(Process process)
        {
            this.process = process;

			var row_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			row_box.margin = 10;
        	load_label = new Gtk.Label(null);
        	load_label.ellipsize = Pango.EllipsizeMode.END;
        	load_label.max_width_chars = 30;

            var icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);
            icon.width_request = 24;
            icon.height_request = 24;
            icon.margin_left = 10;
            icon.margin_right = 10;
            var title_label = new Gtk.Label(process.cmdline);
            row_box.pack_start(icon, false, false, 0);
            row_box.pack_start(title_label, false, true, 5);
            row_box.pack_end(load_label, false, true, 10);
            this.add(row_box);

            update();
            show_all();
        }

        private void update()
        {
            load_label.set_label(((int) process.cpu_load).to_string() + " %");

            if(process.cpu_load >= 90)
                max_usage = true;
            else
                max_usage = false;
        }

        public void activate()
        {
            var dialog = new ProcessDialog(process.pid, process.cmdline);
            dialog.show_all();
        }
    }
}
