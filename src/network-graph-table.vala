using Rg;

namespace Usage {

    public class NetworkGraphTable : Rg.Table
    {
        public const int column_download_id = 0;
        public const int column_upload_id = 1;
        private double max_value = 10;

        public NetworkGraphTable ()
        {
            var settings = (GLib.Application.get_default() as Application).settings;
            set_timespan (settings.graph_timespan * 1000);
            set_max_samples (settings.graph_max_samples);

            var column_download = new Rg.Column("DOWNLOAD", Type.from_name("gdouble"));
            add_column(column_download);
            var column_upload = new Rg.Column("UPLOAD", Type.from_name("gdouble"));
            add_column(column_upload);

            Timeout.add(settings.graph_update_interval, update_data);
        }

        bool update_data()
        {
            Rg.TableIter iter;
            push (out iter, get_monotonic_time ());

            SystemMonitor monitor = (GLib.Application.get_default() as Application).get_system_monitor();

            double net_download = monitor.net_download_actual;
            double net_upload = monitor.net_upload_actual;

            iter.set (column_download_id, net_download, -1);
            iter.set (column_upload_id, net_upload, -1);

            double max_iter_value_download = get_max_iter_value(column_download_id);
            double max_iter_value_upload = get_max_iter_value(column_upload_id);

            double max_iter_value = max_iter_value_download > max_iter_value_upload ? max_iter_value_download : max_iter_value_upload;

            if(max_iter_value > max_value)
                max_value = max_iter_value * 1.5;
            else
                if(max_iter_value < (max_value/3))
                max_value = max_iter_value * 1.5;

            if(max_value < 10)
                max_value = 10;

            this.value_max = max_value;

            return true;
        }
    }
}
