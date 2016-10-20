using Rg;

namespace Usage
{
    public class CpuGraphSingle : Rg.Graph
    {
		private static CpuGraphTable table;

        public CpuGraphSingle ()
        {
            if(table == null)
            {
                table = new CpuGraphTable(false);
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

    public class CpuGraphMulti : Rg.Graph
    {
        static string[] colors =
        {
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

        public CpuGraphMulti ()
        {
            if(table == null)
            {
                table = new CpuGraphTable(true);
                set_table(table);
            }
            else
                set_table(table);

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
