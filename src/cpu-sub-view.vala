namespace Usage
{
    public class ProcessorSubView : View
    {
        public ProcessorSubView()
        {
            name = "PROCESSOR";

            var label =  new Gtk.Label("<span font_desc=\"14.0\">" + _("Processor") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 20;
            label.margin_bottom = 15;

            var cpu_graph = new CpuGraphAllCores();
            cpu_graph.hexpand = true;
            var cpu_graph_box = new GraphBox(cpu_graph);
            cpu_graph_box.height_request = 225;
            cpu_graph_box.width_request = 600;
            cpu_graph_box.valign = Gtk.Align.START;

            var process_list_box = new ProcessListBoxNew();
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var cpu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            cpu_box.pack_start(label, false, false, 0);
            cpu_box.pack_start(cpu_graph_box, false, false, 0);
            cpu_box.pack_start(process_list_box, false, false, 0);

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
