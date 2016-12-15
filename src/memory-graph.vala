using Rg;

namespace Usage
{
    public class MemoryGraph : Rg.Graph
    {
		private static MemoryGraphTable rg_table;
		private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public MemoryGraph ()
        {
            line_color_max.parse("#ee2222");
            line_color_normal.parse("#4a90d9");
            color_max.parse("#fbcccc");
            color_normal.parse("#c4dbff");

            if(rg_table == null)
            {
                rg_table = new MemoryGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            var renderer_ram = new StackedRenderer();
            renderer_ram.column = MemoryGraphTable.column_ram_id;
            renderer_ram.stroke_color_rgba = line_color_normal;
            renderer_ram.stacked_color_rgba = color_normal;
            renderer_ram.line_width = 1.2;
            add_renderer(renderer_ram);

            rg_table.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_max;
                renderer_ram.stacked_color_rgba = color_max;
            });

            rg_table.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });
        }
    }

    public class MemoryGraphBig : Rg.Graph
    {
		private static MemoryGraphTable rg_table;
		private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;
        private Gdk.RGBA color_swap;

        class construct
        {
            set_css_name("rg-graph");
        }

        public MemoryGraphBig()
        {
            color_max.parse("#ee2222");
            color_normal.parse("#4a90d9");
            color_swap.parse("#ff9900");
            get_style_context().add_class("big");

            if(rg_table == null)
            {
                rg_table = new MemoryGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            LineRenderer renderer_ram = new LineRenderer();
            renderer_ram.column = MemoryGraphTable.column_ram_id;
            renderer_ram.stroke_color_rgba = color_normal;
            renderer_ram.line_width = 1.5;
            add_renderer(renderer_ram);

            LineRenderer renderer_swap = new LineRenderer();
            renderer_swap.column = MemoryGraphTable.column_swap_id;
            renderer_swap.stroke_color_rgba = color_swap;
            renderer_swap.line_width = 1.5;
            add_renderer(renderer_swap);

            rg_table.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = color_max;
            });

            rg_table.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = color_normal;
            });
        }
    }
}
