namespace Usage
{
    public class GraphSwitcherButton : Gtk.ToggleButton
    {
        public GraphSwitcherButton.processor(string label)
        {
            Rg.Graph processor_graph = new CpuGraphSingle(60000, 60);
            child = createContent(processor_graph, label);
            relief = Gtk.ReliefStyle.NONE;
        }

        public GraphSwitcherButton.memory(string label)
        {
            Rg.Graph memory_graph = new MemoryGraph(60000, 60);
            child = createContent(memory_graph, label);
            relief = Gtk.ReliefStyle.NONE;
        }

        public GraphSwitcherButton.disk(string label)
        {
            Rg.Graph disk_graph = new CpuGraphSingle(60000, 60);
            child = createContent(disk_graph, label);
            relief = Gtk.ReliefStyle.NONE;
        }

        public GraphSwitcherButton.network(string label)
        {
            Rg.Graph network_graph = new CpuGraphSingle(60000, 60);
            child = createContent(network_graph, label);
            relief = Gtk.ReliefStyle.NONE;
        }

        private Gtk.Box createContent(Rg.Graph graph, string label_text)
        {
            var graph_frame = new Gtk.Frame(null);
            graph_frame.height_request = 80;
            graph_frame.margin_top = 12;
            graph_frame.margin_start = 8;
            graph_frame.margin_end = 8;
            graph_frame.add(graph);

            var label = new Gtk.Label(label_text);
            label.margin_top = 6;
            label.margin_bottom = 3;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(graph_frame, true, true, 0);
            box.pack_start(label, false, false, 0);

            return box;
        }
    }
}
