using Gtk;

namespace Usage {

    public class Settings : Object{

        public uint graph_timespan { get; set; default = 60000;}
        public uint graph_max_samples { get; set; default = 60; }
        public uint graph_update_interval { get { return graph_timespan / (graph_max_samples - 1); }}
        public uint list_update_interval { get; set; default = 1000; }
    }
}
