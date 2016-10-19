using Rg;

namespace Usage {

    public class CpuGraphTable : Rg.Table
    {
        bool multi;

        public CpuGraphTable (uint timespan, uint max_samples, bool multi = false)
        {
            this.multi = multi;
            set_timespan (timespan * 1000);
            set_max_samples (max_samples);

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

            var interval = timespan / (max_samples - 1);
            var monitor = (GLib.Application.get_default() as Application).monitor;
            //TODO change and move to settings
            if(interval < monitor.get_update_graph_interval())
                monitor.set_update_graph_interval(interval);

            Timeout.add(timespan / (max_samples - 1), update_data);
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
