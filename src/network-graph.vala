using Rg;

namespace Usage
{
    public class NetworkGraph : Rg.Graph
    {
		private static NetworkGraphTable rg_table;
        private Gdk.RGBA color_download;
        private Gdk.RGBA color_line_download;
        private Gdk.RGBA color_upload;
        private Gdk.RGBA color_line_upload;

        class construct
        {
            set_css_name("rg-graph");
        }

        public NetworkGraph ()
        {
            color_line_download.parse("#4a90d9");
            color_download.parse("#c4dbff");

            color_line_upload.parse("#ff9900");
            color_upload.parse("#fcd8a2");

            if(rg_table == null)
            {
                rg_table = new NetworkGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            var renderer_download = new StackedRenderer();
            renderer_download.column = NetworkGraphTable.column_download_id;
            renderer_download.stroke_color_rgba = color_line_download;
            renderer_download.stacked_color_rgba = color_download;
            renderer_download.line_width = 1.2;
            add_renderer(renderer_download);

            var renderer_upload = new StackedRenderer();
            renderer_upload.column = NetworkGraphTable.column_upload_id;
            renderer_upload.stroke_color_rgba = color_line_upload;
            renderer_upload.stacked_color_rgba = color_upload;
            renderer_upload.line_width = 1.2;
            add_renderer(renderer_upload);
        }
    }

    public class NetworkGraphBig : Rg.Graph
    {
		private static NetworkGraphTable rg_table;
        private Gdk.RGBA color_download;
        private Gdk.RGBA color_upload;

        class construct
        {
            set_css_name("rg-graph");
        }

        public NetworkGraphBig()
        {
            color_download.parse("#4a90d9");
            color_upload.parse("#ff9900");
            get_style_context().add_class("big");

            if(rg_table == null)
            {
                rg_table = new NetworkGraphTable();
                set_table(rg_table);
            }
            else
                set_table(rg_table);

            LineRenderer renderer_download = new LineRenderer();
            renderer_download.column = NetworkGraphTable.column_download_id;
            renderer_download.stroke_color_rgba = color_download;
            renderer_download.line_width = 1.5;
            add_renderer(renderer_download);

            LineRenderer renderer_upload = new LineRenderer();
            renderer_upload.column = NetworkGraphTable.column_upload_id;
            renderer_upload.stroke_color_rgba = color_upload;
            renderer_upload.line_width = 1.5;
            add_renderer(renderer_upload);
        }
    }
}
