using Rg;

namespace Usage {

    public class CpuGraphTable : Rg.Table
    {
        bool multi;

        public CpuGraphTable (bool multi = false)
        {
            this.multi = multi;
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            if(multi)
            {
                for (int i = 0; i < get_num_processors(); i++)
                {
                    var column = new Rg.Column("CPU: " + i.to_string(), Type.from_name("gdouble"));
                    add_column(column);
                }
            }
            else
            {
                var column = new Rg.Column("TOTAL CPU", Type.from_name("gdouble"));
                add_column(column);
            }

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());

            if(multi)
            {
                for (int i = 0; i < get_num_processors(); i++)
                    iter.set (i, (GLib.Application.get_default() as Application).monitor.x_cpu_load_graph[i], -1);
            }
            else
                iter.set (0, (GLib.Application.get_default() as Application).monitor.cpu_load_graph, -1);

            return true;
        }
    }
}
