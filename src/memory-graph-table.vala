using Rg;

namespace Usage {

    public class MemoryGraphTable : Rg.Table
    {
        public const int column_ram_id = 0;
        public const int column_swap_id = 1;

        public MemoryGraphTable ()
        {
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_ram = new Rg.Column("RAM", Type.from_name("gdouble"));
            add_column(column_ram);
            var column_swap = new Rg.Column("SWAP", Type.from_name("gdouble"));
            add_column(column_swap);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());
            iter.set (column_ram_id, (GLib.Application.get_default() as Application).monitor.mem_usage, -1);
            iter.set (column_swap_id, (GLib.Application.get_default() as Application).monitor.swap_usage, -1);

            return true;
        }
    }
}
