using Gtk;

namespace Usage {

    public class Settings : Object {

        public uint graph_timespan { get; set; default = 30000;}
        public uint graph_max_samples { get; set; default = 30; }
        public uint graph_update_interval { get { return graph_timespan / (graph_max_samples - 1); }}
        public uint list_update_interval { get; set; default = 3000; }
    }
}
