using Gtk;

namespace Usage {

    public class GraphBox : Gtk.Box {

        class construct
        {
            set_css_name("graph-box");
        }

        public GraphBox (Rg.Graph graph) {
            add(graph);
        }
    }
}
