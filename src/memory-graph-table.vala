using Rg;

namespace Usage {

    public class MemoryGraphTable : Rg.Table
    {
        public const int column_ram_id = 0;
        public const int column_swap_id = 1;
        public signal void big_ram_usage();
        public signal void small_ram_usage();
        private bool change_big_ram_usage = true;
        private bool change_small_ram_usage = true;

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

            SystemMonitor monitor = (GLib.Application.get_default() as Application).monitor;
            double ram_usage = monitor.mem_usage;

            iter.set (column_ram_id, ram_usage, -1);
            iter.set (column_swap_id, (GLib.Application.get_default() as Application).monitor.swap_usage, -1);

            if(ram_usage >= 90)
            {
                if(change_big_ram_usage)
                {
                    big_ram_usage();
                    change_big_ram_usage = false;
                    change_small_ram_usage = true;
                }
            }
            else
            {
                if(change_small_ram_usage)
                {
                    small_ram_usage();
                    change_small_ram_usage = false;
                    change_big_ram_usage = true;
                }
            }

            return true;
        }
    }
}
