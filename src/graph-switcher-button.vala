namespace Usage
{
    public class GraphSwitcherButton : Gtk.ToggleButton
    {
        public GraphSwitcherButton.processor(string label)
        {
            Rg.Graph processor_graph = new CpuGraphMostUsed();
            child = createContent(processor_graph, label);
        }

        public GraphSwitcherButton.memory(string label)
        {
            Rg.Graph memory_graph = new MemoryGraph();
            child = createContent(memory_graph, label);
        }

        public GraphSwitcherButton.disk(string label)
        {
            Rg.Graph disk_graph = new DiskGraph();
            child = createContent(disk_graph, label);
        }

        private Gtk.Box createContent(Rg.Graph graph, string label_text)
        {
            graph.height_request = 80;
            graph.hexpand = true;
            var graph_box = new GraphBox(graph);
            graph_box.margin_top = 12;
            graph_box.margin_start = 8;
            graph_box.margin_end = 8;

            var label = new Gtk.Label(label_text);
            label.margin_top = 6;
            label.margin_bottom = 3;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(graph_box, true, true, 0);
            box.pack_start(label, false, false, 0);

            return box;
        }

        class construct
        {
            set_css_name("graph-switcher-button");
        }
    }
}
