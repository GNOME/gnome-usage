namespace Usage
{
    public class ProcessorSubView : View
    {
        public ProcessorSubView()
        {
            name = "PROCESSOR";

            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Processor") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 25;
            label.margin_bottom = 15;

            var cpu_graph = new CpuGraphBig();
            cpu_graph.hexpand = true;
            var cpu_graph_box = new GraphBox(cpu_graph);
            cpu_graph_box.height_request = 225;
            cpu_graph_box.width_request = 600;
            cpu_graph_box.valign = Gtk.Align.START;

            var process_list_box = new ProcessListBox(ProcessListBoxType.PROCESSOR);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            var cpu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            cpu_box.pack_start(label, false, false, 0);
            cpu_box.pack_start(cpu_graph_box, false, false, 0);
            cpu_box.pack_start(spinner, true, true, 0);

            var no_process_label = new Gtk.Label("<span font_desc=\"14.0\">" + _("No application using processor.") + "</span>");
            no_process_label.set_use_markup(true);
            no_process_label.get_style_context().add_class("dim-label");

            (GLib.Application.get_default() as Application).get_system_monitor().cpu_processes_ready.connect(() =>
            {
                cpu_box.pack_start(process_list_box, false, false, 0);
                cpu_box.pack_start(no_process_label, true, true, 0);
                process_list_box.update();
                cpu_box.remove(spinner);
            });

            process_list_box.empty.connect(() =>
            {
                no_process_label.show();
            });

            process_list_box.filled.connect(() =>
            {
                no_process_label.hide();
            });

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
    }
}
