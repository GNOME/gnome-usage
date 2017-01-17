namespace Usage
{
    public class MemorySubView : View
    {
        public MemorySubView()
        {
            name = "MEMORY";

            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Memory") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 25;
            label.margin_bottom = 15;

            var memory_graph = new MemoryGraphBig();
            memory_graph.hexpand = true;
            var memory_graph_box = new GraphBox(memory_graph);
            memory_graph_box.height_request = 225;
            memory_graph_box.width_request = 600;
            memory_graph_box.valign = Gtk.Align.START;

            var process_list_box = new ProcessListBox(ProcessListBoxType.MEMORY);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            memory_box.pack_start(label, false, false, 0);
            memory_box.pack_start(memory_graph_box, false, false, 0);
            memory_box.pack_start(spinner, true, true, 0);

            var no_process_label = new Gtk.Label("<span font_desc=\"14.0\">" + _("No application using memory.") + "</span>");
            no_process_label.set_use_markup(true);
            no_process_label.get_style_context().add_class("dim-label");

            (GLib.Application.get_default() as Application).get_system_monitor().cpu_processes_ready.connect(() =>
            {
                memory_box.pack_start(process_list_box, false, false, 0);
                memory_box.pack_start(no_process_label, true, true, 0);
                process_list_box.update();
                memory_box.remove(spinner);
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
            better_box.add(memory_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);
        }
    }
}
