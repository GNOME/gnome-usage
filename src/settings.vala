using Gtk;

namespace Usage {

    public class Settings : Object
    {
        public uint graph_timespan { get; set; default = 15000;}
        public uint graph_max_samples { get; set; default = 20; }
        public uint graph_update_interval { get { return 1000; }}
        public uint list_update_interval_UI { get; set; default = 5000; }
        public uint list_update_pie_charts_UI { get; set; default = 1000; }
        public uint data_update_interval { get; set; default = 1000; }
    }
}
