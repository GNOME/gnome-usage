using Rg;

namespace Usage {

    public class MemoryGraphTable : Rg.Table
    {
        public const int column_ram_id = 0;
        public const int column_swap_id = 1;

        public MemoryGraphTable (uint timespan, uint max_samples)
        {
            set_timespan (timespan * 1000);
            set_max_samples (max_samples);

            var column_ram = new Rg.Column("RAM", Type.from_name("gdouble"));
            add_column(column_ram);
            var column_swap = new Rg.Column("SWAP", Type.from_name("gdouble"));
            add_column(column_swap);

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
            iter.set (column_ram_id, (GLib.Application.get_default() as Application).monitor.mem_usage_graph, -1);
            iter.set (column_swap_id, (GLib.Application.get_default() as Application).monitor.swap_usage_graph, -1);

            return true;
        }
    }
}
