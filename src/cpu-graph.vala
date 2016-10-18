using Rg;

namespace Usage {

    public class CpuGraph : Rg.Graph {

        static string[] colors = {
          "#73d216",
          "#ef2929",
          "#3465a4",
          "#f57900",
          "#75507b",
          "#ce5c00",
          "#c17d11",
          "#ce5c00",
        };

		private static CpuGraphTable table;
		private static CpuGraphTable table_multi;

        public CpuGraph (int64 timespan, int64 max_samples)
        {
            if(table == null)
            {
                table = new CpuGraphTable(30000, 60);
                set_table(table);
            }
            else
                set_table(table);

            LineRenderer renderer = new LineRenderer();
            renderer.stroke_color = colors [1];
            renderer.line_width = 2;
            add_renderer(renderer);
        }

        public CpuGraph.multi (int64 timespan, int64 max_samples)
        {
            if(table_multi == null)
            {
                table_multi = new CpuGraphTable.multi(30000, 60);
                set_table(table_multi);
            }
            else
                set_table(table_multi);

            for(int i = 0; i < get_num_processors(); i++)
            {
                LineRenderer renderer = new LineRenderer();
                renderer.column = i;
                renderer.stroke_color = colors [i % colors.length];
                renderer.line_width = 2;
                add_renderer(renderer);
            }
        }
    }
}
