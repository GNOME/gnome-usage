using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
    	private pid_t pid;
        GraphBlock processor_graph_block;
        GraphBlock memory_graph_block;
        GraphBlock disk_graph_block;
        GraphBlock downloads_graph_block;
        GraphBlock uploads_graph_block;
        GraphBlock network_graph_block;

    	public ProcessDialog(pid_t pid, string name)
    	{
    	    Object(use_header_bar: 1);
    	    set_transient_for((GLib.Application.get_default() as Application).window);
    	    set_position(Gtk.WindowPosition.CENTER);
    	    set_resizable(false);
    	    this.pid = pid;
    		this.title = name;
    		this.border_width = 5;
    		set_default_size (900, 350);
    		create_widgets();
    		connect_signals();
    	}

    	private void create_widgets()
    	{
    		Gtk.Box content = get_content_area() as Gtk.Box;

            Gtk.Grid grid = new Gtk.Grid();
            grid.margin_top = 20;
            grid.margin_start = 20;
            grid.margin_end = 20;

            processor_graph_block = new GraphBlock(_("Processor"), this.title);
            memory_graph_block = new GraphBlock(_("Memory"), this.title);
            disk_graph_block = new GraphBlock(_("Disk I/O"), this.title);
            downloads_graph_block = new GraphBlock(_("Downloads"), this.title);
            uploads_graph_block = new GraphBlock(_("Uploads"), this.title);
            network_graph_block = new GraphBlock(_("All network"), this.title);

            grid.attach(processor_graph_block, 0, 0, 1, 1);
            grid.attach(memory_graph_block, 1, 0, 1, 1);
            grid.attach(disk_graph_block, 2, 0, 1, 1);
            grid.attach(downloads_graph_block, 0, 1, 1, 1);
            grid.attach(uploads_graph_block, 1, 1, 1, 1);
            grid.attach(network_graph_block, 2, 1, 1, 1);
            content.add(grid);
            content.show_all();

            Timeout.add((GLib.Application.get_default() as Application).settings.list_update_cookie_graphs_UI, update);
            update();

    		add_button (_("Stop"), Gtk.ResponseType.HELP).get_style_context().add_class ("destructive-action");
    	}

    	private bool update()
    	{
    	    unowned SystemMonitor monitor = (GLib.Application.get_default() as Application).monitor;
    	    unowned Process data = monitor.get_process_by_pid(pid);

    	    int app_cpu_load = 0;
    	    int app_memory_usage = 0;
    	    int app_download = 0;
    	    int app_upload = 0;
    	    int app_network = 0;

    	    int other_download = 0;
            int other_upload = 0;
            int other_network = 0;

    	    if(data != null)
    	    {
    	        app_cpu_load = (int) data.cpu_load;
    	        app_memory_usage = (int) data.mem_usage_percentages;
    	        processor_graph_block.update((int) data.last_processor, app_cpu_load, (int) monitor.x_cpu_load[data.last_processor]-app_cpu_load);

                double download_one_percentage = monitor.net_download / 100;
                if(download_one_percentage != 0)
                {
                    app_download = (int) (data.net_download / download_one_percentage);
                    app_download = int.min(app_download, 100);
                    other_download = 100 - app_download;
                }

                double upload_one_percentage = monitor.net_upload / 100;
                if(upload_one_percentage != 0)
                {
                    app_upload = (int) (data.net_upload / upload_one_percentage);
                    app_upload = int.min(app_upload, 100);
                    other_upload = 100 - app_upload;
                }

                double net_one_percentage = monitor.net_usage / 100;
                if(net_one_percentage != 0)
                {
                    app_network = (int) (data.net_all / net_one_percentage);
                    app_network = int.min(app_network, 100);
                    other_network = 100 - app_network;
                }
    	    }
    	    else
    	    {
    	        processor_graph_block.update(-1, 0, (int) monitor.cpu_load);
    	    }

    	    memory_graph_block.update(-1, app_memory_usage, (int) monitor.ram_usage);
    	    downloads_graph_block.update(-1, app_download, other_download);
            uploads_graph_block.update(-1, app_upload, other_upload);
            network_graph_block.update(-1, app_network, other_network);
    	    return true;
    	}

    	private void connect_signals()
    	{
    		this.response.connect (on_response);
    	}

    	private void on_response(Gtk.Dialog source, int response_id)
    	{
    		switch(response_id)
    		{
    		    case Gtk.ResponseType.HELP:
    		        kill_process(pid);
    		    	destroy();
    		    	break;
    		    case Gtk.ResponseType.CLOSE:
    		    	destroy();
    		    	break;
    		}
    	}

        private void kill_process(pid_t pid)
    	{
             Posix.kill (pid, Posix.SIGKILL);
    	}
    }
}