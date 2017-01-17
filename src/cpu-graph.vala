using Rg;

namespace Usage
{
    /**
     *  Graph showing most used core
    **/
    public class CpuGraphMostUsed : Rg.Graph
    {
		private static CpuGraphTableMostUsedCore rg_table;
		private StackedRenderer renderer;
		private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public CpuGraphMostUsed ()
        {
            get_style_context().add_class("line_max");
            line_color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_max");
            get_style_context().add_class("line");
            line_color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("stacked_max");
            color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked_max");
            get_style_context().add_class("stacked");
            color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked");

            if(rg_table == null)
                rg_table = new CpuGraphTableMostUsedCore();

            set_table(rg_table);

            renderer = new StackedRenderer();
            renderer.stroke_color_rgba = line_color_normal;
            renderer.stacked_color_rgba = color_normal;
            renderer.line_width = 1.0;
            add_renderer(renderer);

            rg_table.big_process_usage.connect (() => {
                renderer.stroke_color_rgba = line_color_max;
                renderer.stacked_color_rgba = color_max;
            });

            rg_table.small_process_usage.connect (() => {
                renderer.stroke_color_rgba = line_color_normal;
                renderer.stacked_color_rgba = color_normal;
            });
        }
    }

    /**
     *  Graph showing all processor cores.
    **/
    public class CpuGraphBig : Rg.Graph
    {
    	private static CpuGraphTableComplex rg_table;
        private LineRenderer[] renderers;
        private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public CpuGraphBig()
        {
            get_style_context().add_class("line_max");
            line_color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_max");
            get_style_context().add_class("line");
            line_color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("big");

            if(rg_table == null)
                rg_table = new CpuGraphTableComplex();

            set_table(rg_table);

            renderers = new LineRenderer[get_num_processors()];
            for(int i = 0; i < get_num_processors(); i++)
            {
                renderers[i] = new LineRenderer();
                renderers[i].column = i;
                renderers[i].stroke_color_rgba = line_color_normal;
                renderers[i].line_width = 1.5;
                add_renderer(renderers[i]);
            }

            rg_table.big_process_usage.connect ((column) => {
                renderers[column].stroke_color_rgba = line_color_max;
                renderers[column].line_width = 2.5;
            });

            rg_table.small_process_usage.connect ((column) => {
                renderers[column].stroke_color_rgba = line_color_normal;
                renderers[column].line_width = 1.5;
            });
        }
    }
}
