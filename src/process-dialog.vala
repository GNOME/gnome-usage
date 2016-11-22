using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
    	private Gtk.Widget kill_button;
    	private pid_t pid;

    	public ProcessDialog(pid_t pid)
    	{
    	    Object(use_header_bar: 1);
    	    this.pid = pid;
    		this.title = "Process";
    		this.border_width = 5;
    		set_default_size (350, 100);
    		create_widgets();
    		connect_signals();
    	}

    	private void create_widgets()
    	{
    		Gtk.Box content = get_content_area() as Gtk.Box;
    		content.spacing = 10;

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