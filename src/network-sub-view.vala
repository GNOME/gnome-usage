namespace Usage
{

    public class NetworkSubView : View, SubView
    {
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
                                                   "/org/gnome/GTop/netstats"); //pls CHECK obj path
            }catch(IOError e) {
                warning ("%s\n", e.message);
            }
            this.network_stats_activate.connect(on_net_stats_activate);
            this.network_stats_deactivate.connect(on_net_stats_deactivate);
            process_list_box = new ProcessListBox(ProcessListBoxType.NETWORK);
            process_list_box.margin_bottom = 20;
            process_list_box.margin_top = 30;

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            no_process_view = new NoResultsFoundView();
            /*graphs are remaining*/

            var network_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            network_box.halign = Gtk.Align.CENTER;
            network_box.pack_start(process_list_box, false, false, 0);
            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(network_box);
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
                warning ("%s\n", e.message);
            }
            try
            {
                this.netstats_dbus.init_capture();
            }catch(IOError e) {
                warning ("%s\n", e.message);
            }
        }

        public void on_net_stats_deactivate ()
        {
            try
            {
                this.netstats_dbus.reset_capture_status();
            }catch(IOError e) {
                warning ("%s\n", e.message);
            }
        }
    }
}
