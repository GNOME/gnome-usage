using Rg;

namespace Usage {

    public class MemoryGraphTable : Rg.Table
    {
        public MemoryGraphTable (uint timespan, uint max_samples)
        {
            set_timespan (timespan * 1000);
            set_max_samples (max_samples);

            var column = new Rg.Column("TOTAL CPU", Type.from_name("gdouble"));
            add_column(column);

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
            iter.set (0, (GLib.Application.get_default() as Application).monitor.mem_usage_graph, -1);

            return true;
        }
    }
}
