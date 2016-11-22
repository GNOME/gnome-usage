using Rg;

namespace Usage
{
    public class MemoryGraph: Rg.Graph
    {
		private static MemoryGraphTable rg_table;

        public MemoryGraph ()
        {
            if(rg_table == null)
            {
                rg_table = new MemoryGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            LineRenderer renderer_ram = new LineRenderer();
            renderer_ram.column = MemoryGraphTable.column_ram_id;
            renderer_ram.stroke_color = "#ef2929";
            renderer_ram.line_width = 2;
            add_renderer(renderer_ram);

            LineRenderer renderer_swap = new LineRenderer();
            renderer_swap.column = MemoryGraphTable.column_swap_id;
            renderer_swap.stroke_color = "#73d216";
            renderer_swap.line_width = 2;
            add_renderer(renderer_swap);
        }
    }
}
