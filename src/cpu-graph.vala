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
		private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public CpuGraphMostUsed ()
        {
            color_max.parse("#ee2222");
            color_normal.parse("#4a90d9");

            if(rg_table == null)
                rg_table = new CpuGraphTableMostUsedCore();

            set_table(rg_table);

            renderer = new LineRenderer();
            renderer.stroke_color_rgba = color_normal;
            renderer.line_width = 1.2;
            add_renderer(renderer);

            rg_table.big_process_usage.connect (() => {
                renderer.stroke_color_rgba = color_max;
            });

            rg_table.small_process_usage.connect (() => {
                renderer.stroke_color_rgba = color_normal;
            });
        }
    }

    /**
     *  Graph showing all processor cores.
    **/
    public class CpuGraphBig : Rg.Graph
    {
    	private static CpuGraphTableComplex table;
        private LineRenderer[] renderers;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public CpuGraphBig()
        {
            color_max.parse("#ee2222");
            color_normal.parse("#4a90d9");
            get_style_context().add_class("big");

            if(table == null)
                table = new CpuGraphTableComplex();

            set_table(table);

            renderers = new LineRenderer[get_num_processors()];
            for(int i = 0; i < get_num_processors(); i++)
            {
                renderers[i] = new LineRenderer();
                renderers[i].column = i;
                renderers[i].stroke_color_rgba = color_normal;
                renderers[i].line_width = 1.5;
                add_renderer(renderers[i]);
            }

            table.big_process_usage.connect ((column) => {
                renderers[column].stroke_color_rgba = color_max;
            });

            table.small_process_usage.connect ((column) => {
                renderers[column].stroke_color_rgba = color_normal;
            });
        }
    }
}
