using Rg;

namespace Usage
{
    public class NetworkGraph : Rg.Graph
    {   /*TODO*/
        //this can be used to display total data transfer in the graph-stack-switcher-button 
		private Gdk.RGBA line_color_received;
        private Gdk.RGBA color_sent;

        class construct
        {
            set_css_name("rg-graph");
        }

        public NetworkGraph ()
        {
            
        }
    }
}
