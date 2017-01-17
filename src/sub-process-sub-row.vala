using Posix;

namespace Usage
{
    public class SubProcessSubRow : Gtk.ListBoxRow
    {
        Gtk.Label load_label;
        ProcessListBoxType type;
        public Process process { get; private set; }
        public bool max_usage { get; private set; }

        public SubProcessSubRow(Process process, ProcessListBoxType type)
        {
            this.type = type;
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
            var title_label = new Gtk.Label(process.get_cmdline());
            row_box.pack_start(icon, false, false, 0);
            row_box.pack_start(title_label, false, true, 5);
            row_box.pack_end(load_label, false, true, 10);
            this.add(row_box);

            notify["max-usage"].connect (() => {
                set_styles();
            });
            update();
            show_all();
        }

        private void update()
        {
            switch(type)
            {
                case ProcessListBoxType.PROCESSOR:
                    load_label.set_label(((uint64) process.get_cpu_load()).to_string() + " %");

                    if(process.get_cpu_load() >= 90)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
                case ProcessListBoxType.MEMORY:
                    load_label.set_label(Utils.format_size_values(process.get_mem_usage()));

                    if(process.get_mem_usage_percentages() >= 90)
                        max_usage = true;
                    else
                        max_usage = false;
                    break;
                case ProcessListBoxType.NETWORK:
                    load_label.set_label(Utils.format_size_values(process.get_net_all()));
                    break;
            }
        }

        private void set_styles()
        {
            if(max_usage == true)
                get_style_context().add_class("max");
            else
                get_style_context().remove_class("max");
        }

        public new void activate()
        {
            var dialog = new ProcessDialog(process.get_pid(), process.get_cmdline(), process.get_cmdline());
            dialog.show_all();
        }
    }
}
