using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
    	private pid_t pid;

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
            Gtk.AttachOptions flags = Gtk.AttachOptions.EXPAND;

            Gtk.Table table = new Gtk.Table (2, 3, true);
            table.vexpand = true;

            var processor_graph_block = new GraphBlock(_("Processor"), this.title);
            var memory_graph_block = new GraphBlock(_("Memory"), this.title);
            var disk_graph_block = new GraphBlock(_("Disk I/O"), this.title);
            var downloads_graph_block = new GraphBlock(_("Downloads"), this.title);
            var uploads_graph_block = new GraphBlock(_("Uploads"), this.title);

            table.attach(processor_graph_block, 0, 1, 0, 1, flags, flags, 0, 0);
            table.attach(memory_graph_block, 1, 2, 0, 1, flags, flags, 0, 0);
            table.attach(disk_graph_block, 2, 3, 0, 1, flags, flags, 0, 0);
            table.attach(downloads_graph_block, 0, 1, 1, 2, flags, flags, 0, 0);
            table.attach(uploads_graph_block, 1, 2, 1, 2, flags, flags, 0, 0);
            content.add(table);
            content.show_all();

            int i = 1;

            Timeout.add(1000, () => //testing
            {
                processor_graph_block.update(i, i*2);
                i++;
                return true;
            });

    		add_button (_("Stop"), Gtk.ResponseType.HELP).get_style_context().add_class ("destructive-action");
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