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
            color_max.parse("rgba(238,34,34,0.227)");
            line_color_max.parse("rgba(238,34,34,1)");
            color_normal.parse("rgba(74,144,217,0.325)");
            line_color_normal.parse("rgba(74,144,217,1)");

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
		private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;
        private Gdk.RGBA color_max;
        private Gdk.RGBA color_normal;

        class construct
        {
            set_css_name("rg-graph");
        }

        public MemoryGraphBig()
        {
            color_max.parse("rgba(238,34,34,0.227)");
            line_color_max.parse("rgba(238,34,34,1)");
            color_normal.parse("rgba(74,144,217,0.325)");
            line_color_normal.parse("rgba(74,144,217,1)");
            get_style_context().add_class("big");

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
            renderer_ram.line_width = 1.5;
            add_renderer(renderer_ram);

            rg_table.big_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });

            rg_table.small_ram_usage.connect (() => {
                renderer_ram.stroke_color_rgba = line_color_normal;
                renderer_ram.stacked_color_rgba = color_normal;
            });
        }
    }
}
