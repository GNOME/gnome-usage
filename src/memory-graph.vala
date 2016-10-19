using Rg;

namespace Usage
{
    public class MemoryGraph: Rg.Graph
    {
		private static MemoryGraphTable table;

        public MemoryGraph (uint timespan, uint max_samples)
        {
            if(table == null)
            {
                table = new MemoryGraphTable(timespan, max_samples);
                set_table(table);
            }
            else
                set_table(table);

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
