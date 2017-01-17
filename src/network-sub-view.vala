namespace Usage
{
    public class NetworkSubView : View
    {
        public NetworkSubView()
        {
            name = "NETWORK";

            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Network") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 25;
            label.margin_bottom = 15;

            var network_graph = new NetworkGraphBig();
            network_graph.hexpand = true;
            var network_graph_box = new GraphBox(network_graph);
            network_graph_box.height_request = 225;
            network_graph_box.width_request = 600;
            network_graph_box.valign = Gtk.Align.START;

            var process_list_box = new ProcessListBox(ProcessListBoxType.NETWORK);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            var network_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            network_box.pack_start(label, false, false, 0);
            network_box.pack_start(network_graph_box, false, false, 0);

            var no_process_label = new Gtk.Label("<span font_desc=\"14.0\">" + _("No application using network.") + "</span>");
            no_process_label.set_use_markup(true);
            no_process_label.get_style_context().add_class("dim-label");

            (GLib.Application.get_default() as Application).get_system_monitor().cpu_processes_ready.connect(() =>
            {
                network_box.pack_start(process_list_box, false, false, 0);
                network_box.pack_start(no_process_label, true, true, 0);
                process_list_box.update();
                network_box.remove(spinner);
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
            better_box.add(network_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);
        }
    }
}
