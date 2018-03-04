namespace Usage
{

    public class NetworkSubView : View, SubView
    {
        public signal void network_stats_activate();
        public signal void network_stats_deactivate();
        private ProcessListBox process_list_box;
        private NoResultsFoundView no_process_view;
        public static NetStats netstats_dbus;
        public NetworkSubView()
        {
            name = "NETWORK";
            //get the dbus connection
            try{
                netstats_dbus = Bus.get_proxy_sync (BusType.SYSTEM,
                                                   "org.gnome.GTop.NetStats",
                                                   "/org/gnome/GTop/NetStats"); //pls CHECK obj path
            }catch(IOError e) {
                stderr.printf ("%s\n", e.message);
            }
            this.network_stats_activate.connect(on_net_stats_activate);
            process_list_box = new ProcessListBox(ProcessListBoxType.NETWORK);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            no_process_view = new NoResultsFoundView();
            /*graphs are remaining*/

            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            memory_box.halign = Gtk.Align.CENTER;
            memory_box.pack_start(spinner, true, true, 0);
            memory_box.add(no_process_view);

            process_list_box.bind_property ("empty", no_process_view, "visible", BindingFlags.BIDIRECTIONAL);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(memory_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);
        }

        public override void show_all() {
            base.show_all();
            this.no_process_view.hide();
        }

        public void search_in_processes(string text)
        {
            process_list_box.search(text);
        }

        public void on_net_stats_activate ()
        {
            try
            {
                this.netstats_dbus.set_capture_status();
            }catch(IOError e) {
                stderr.printf ("%s\n", e.message);
            }         
        }
        public void on_net_stats_deactivate ()
        {
            try
            {   
                this.netstats_dbus.reset_capture_status();
            }catch(IOError e) {
                stderr.printf ("%s\n", e.message);
            }
        }
    }
}
