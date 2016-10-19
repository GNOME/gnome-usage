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

            LineRenderer renderer = new LineRenderer();
            renderer.stroke_color = "#ef2929";
            renderer.line_width = 2;
            add_renderer(renderer);
        }
    }
}
