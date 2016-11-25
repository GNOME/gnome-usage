using Rg;

namespace Usage
{
    /**
     *  Graph showing most used core
    **/
    public class CpuGraphMostUsed : Rg.Graph
    {
		private static CpuGraphTableMostUsedCore rg_table;
		private LineRenderer renderer;
		private const string red_color = "#ee2222";
        private const string blue_color = "#4a90d9";

        public CpuGraphMostUsed ()
        {
            if(rg_table == null)
            {
                rg_table = new CpuGraphTableMostUsedCore();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            renderer = new LineRenderer();
            renderer.stroke_color = blue_color;
            renderer.line_width = 1.2;
            add_renderer(renderer);

            rg_table.big_process_usage.connect (() => {
                renderer.stroke_color = red_color;
            });

            rg_table.small_process_usage.connect (() => {
                renderer.stroke_color = blue_color;
            });
        }
    }

    /**
     *  Graph showing all processor cores.
    **/
    public class CpuGraphAllCores : Rg.Graph
    {
    	private static CpuGraphTableComplex rg_table;
        private LineRenderer[] renderers;
        private const string red_color = "#ee2222";
        private const string blue_color = "#a8c9ed";

        public CpuGraphAllCores ()
        {
            name = "CpuGraphAllCores";
            if(rg_table == null)
            {
                rg_table = new CpuGraphTableComplex();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            renderers = new LineRenderer[get_num_processors()];
            for(int i = 0; i < get_num_processors(); i++)
            {
                renderers[i] = new LineRenderer();
                renderers[i].column = i;
                renderers[i].stroke_color = blue_color;
                renderers[i].line_width = 2.5;
                add_renderer(renderers[i]);
            }

            rg_table.big_process_usage.connect ((column) => {
                renderers[column].stroke_color = red_color;
            });

            rg_table.small_process_usage.connect ((column) => {
                renderers[column].stroke_color = blue_color;
            });
        }
    }
}
