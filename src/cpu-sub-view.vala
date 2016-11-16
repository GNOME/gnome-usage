namespace Usage
{
    public class ProcessorSubView : View
    {
        bool show_active_process = true;

        public ProcessorSubView()
        {
            name = "PROCESSOR";

            var label =  new Gtk.Label("<span font_desc=\"14.0\">" + _("Processor") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 20;
            label.margin_bottom = 15;

            var cpu_graph = new CpuGraphAllCores();
            var cpu_graph_frame = new Gtk.Frame(null);
            cpu_graph_frame.height_request = 225;
            cpu_graph_frame.width_request = 600;
            cpu_graph_frame.valign = Gtk.Align.START;
            cpu_graph_frame.add(cpu_graph);

            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_top = 30;
            process_list_box_frame.margin_bottom = 20;
            process_list_box_frame.add(new ProcessListBox());

            var cpu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            cpu_box.pack_start(label, false, false, 0);
            cpu_box.pack_start(cpu_graph_frame, false, false, 0);
            cpu_box.pack_start(process_list_box_frame, false, false, 0);

            var better_box = new Better.Box();
            better_box.max_width_request = 600;
            better_box.halign = Gtk.Align.CENTER;
            better_box.orientation = Gtk.Orientation.HORIZONTAL;
            better_box.add(cpu_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);


            add(scrolled_window);
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
