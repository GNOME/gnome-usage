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
            get_style_context().add_class("line");
            color_line_download = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("stacked");
            color_download = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked");
            get_style_context().add_class("line_orange");
            color_line_upload = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_orange");
            get_style_context().add_class("stacked_orange");
            color_upload = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("stacked_orange");

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
            get_style_context().add_class("line");
            color_download = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("line_orange");
            color_upload = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_orange");
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
