using Rg;

namespace Usage {

    public class CpuGraphTableComplex : Rg.Table
    {
        public signal void big_process_usage (int column);
        public signal void small_process_usage (int column);
        private bool[] change_big_process_usage;
        private bool[] change_small_process_usage;

        public CpuGraphTableComplex ()
        {
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_total = new Rg.Column("TOTAL CPU", Type.from_name("gdouble"));
            add_column(column_total);

            change_big_process_usage = new bool[get_num_processors()];
            change_small_process_usage = new bool[get_num_processors()];

            for (int i = 0; i < get_num_processors(); i++)
            {
                var column_x_cpu = new Rg.Column("CPU: " + i.to_string(), Type.from_name("gdouble"));
                add_column(column_x_cpu);

                change_big_process_usage[i] = true;
                change_small_process_usage[i] = true;
            }

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = (GLib.Application.get_default() as Application).get_system_monitor();

            for (int i = 0; i < get_num_processors(); i++)
            {
                iter.set (i, monitor.x_cpu_load[i], -1);

                if(monitor.x_cpu_load[i] >= 90)
                {
                    if(change_big_process_usage[i])
                    {
                        big_process_usage(i);
                        change_big_process_usage[i] = false;
                        change_small_process_usage[i] = true;
                    }
                }
                else
                {
                    if(change_small_process_usage[i])
                    {
                        small_process_usage(i);
                        change_small_process_usage[i] = false;
                        change_big_process_usage[i] = true;
                    }
                }
            }

            return true;
        }
    }

    public class CpuGraphTableMostUsedCore : Rg.Table
    {
        public signal void big_process_usage ();
        public signal void small_process_usage ();
        private bool change_big_process_usage = true;
        private bool change_small_process_usage = true;

        public CpuGraphTableMostUsedCore ()
        {
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column = new Rg.Column("MOST USED CORE", Type.from_name("gdouble"));
            add_column(column);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = (GLib.Application.get_default() as Application).get_system_monitor();
            double most_used_core = monitor.x_cpu_load[0];

            for (int i = 1; i < get_num_processors(); i++)
            {
                if(monitor.x_cpu_load[i] > most_used_core)
                    most_used_core = monitor.x_cpu_load[i];
            }

            iter.set (0, most_used_core, -1);

            if(most_used_core >= 90)
            {
                if(change_big_process_usage)
                {
                    big_process_usage();
                    change_big_process_usage = false;
                    change_small_process_usage = true;
                }
            }
            else
            {
                if(change_small_process_usage)
                {
                    small_process_usage();
                    change_small_process_usage = false;
                    change_big_process_usage = true;
                }
            }

            return true;
        }
    }
}
