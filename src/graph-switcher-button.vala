namespace Usage
{
    public class GraphSwitcherButton : Gtk.ToggleButton
    {
        public GraphSwitcherButton.processor(string label)
        {
            Rg.Graph processor_graph = new CpuGraphSingle();
            child = createContent(processor_graph, label);
            style_button();
        }

        public GraphSwitcherButton.memory(string label)
        {
            Rg.Graph memory_graph = new MemoryGraph();
            child = createContent(memory_graph, label);
            style_button();
        }

        public GraphSwitcherButton.disk(string label)
        {
            Rg.Graph disk_graph = new CpuGraphSingle();
            child = createContent(disk_graph, label);
            style_button();
        }

        public GraphSwitcherButton.network(string label)
        {
            Rg.Graph network_graph = new CpuGraphSingle();
            child = createContent(network_graph, label);
            style_button();
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

        private void style_button()
        {
            relief = Gtk.ReliefStyle.NONE;
            get_style_context().add_class("sidebar");
            set_can_focus(false);
        }
    }
}
