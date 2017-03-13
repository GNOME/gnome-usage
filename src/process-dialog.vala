using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
	    ProcessDialogHeaderBar headerbar;
    	Pid pid;
    	string process;
        GraphBlock processor_graph_block;
        GraphBlock memory_graph_block;
        GraphBlock disk_graph_block;
        GraphBlock downloads_graph_block;
        GraphBlock uploads_graph_block;

    	public ProcessDialog(Pid pid, string app_name, string process)
    	{
    	    Object(use_header_bar: 1);
    	    set_modal(true);
    	    set_transient_for((GLib.Application.get_default() as Application).get_window());
    	    set_position(Gtk.WindowPosition.CENTER);
    	    set_resizable(false);
    	    this.pid = pid;
    		this.title = app_name;
    		this.process = process;
    		this.border_width = 5;
    		set_default_size (900, 350);
    		create_widgets();
    	}

    	private void create_widgets()
    	{
    		Gtk.Box content = get_content_area() as Gtk.Box;

            Gtk.Grid grid = new Gtk.Grid();
            grid.margin_top = 20;
            grid.margin_start = 20;
            grid.margin_end = 20;

            processor_graph_block = new GraphBlock(GraphBlockType.PROCESSOR, _("Processor"), this.title);
            memory_graph_block = new GraphBlock(GraphBlockType.MEMORY, _("Memory"), this.title);
            disk_graph_block = new GraphBlock(GraphBlockType.DISK, _("Disk I/O"), this.title);
            downloads_graph_block = new GraphBlock(GraphBlockType.NETWORK, _("Downloads"), this.title, false);
            uploads_graph_block = new GraphBlock(GraphBlockType.NETWORK, _("Uploads"), this.title, false);

            grid.attach(processor_graph_block, 0, 0, 1, 1);
            grid.attach(memory_graph_block, 1, 0, 1, 1);
            grid.attach(disk_graph_block, 2, 0, 1, 1);
            grid.attach(downloads_graph_block, 0, 1, 1, 1);
            grid.attach(uploads_graph_block, 1, 1, 1, 1);
            content.add(grid);
            content.show_all();

            var stop_button = new Gtk.Button.with_label(_("Stop"));
            stop_button.get_style_context().add_class ("destructive-action");

            headerbar = new ProcessDialogHeaderBar(stop_button, pid, this.title, process);
            set_titlebar(headerbar);

            Timeout.add((GLib.Application.get_default() as Application).settings.list_update_pie_charts_UI, update);
            update();
    	}

    	private bool update()
    	{
    	    SystemMonitor monitor = (GLib.Application.get_default() as Application).get_system_monitor();
            unowned Process data = monitor.get_process_by_pid(pid);

            ProcessStatus process_status = ProcessStatus.DEAD;
            int app_cpu_load = 0;
            uint64 app_memory_usage = 0;
            uint64 app_net_download = 0;
            uint64 app_net_upload = 0;

            if(data != null)
            {
                app_cpu_load = (int) data.get_cpu_load();
                app_memory_usage = data.get_mem_usage();
                int processor_other = (int) monitor.x_cpu_load[data.get_last_processor()] - app_cpu_load;
                processor_other = int.max(processor_other, 0);
                processor_graph_block.update(app_cpu_load, processor_other, 100, (int) data.get_last_processor());
                process_status = data.get_status();
                app_net_download = data.get_net_download();
                app_net_upload = data.get_net_upload();
            }
            else
                processor_graph_block.update(0, (int) monitor.cpu_load, 100);

            memory_graph_block.update(app_memory_usage, monitor.ram_usage, monitor.ram_total);
            downloads_graph_block.update(app_net_download, monitor.net_download - app_net_download, monitor.net_download);
            uploads_graph_block.update(app_net_upload, monitor.net_upload - app_net_upload, monitor.net_upload);
            headerbar.set_process_state(process_status);
            return true;
    	}
    }

    public class ProcessDialogHeaderBar : Gtk.HeaderBar
    {
        private Gtk.Label label;
        private string app_name;
        private string process;
        private Gtk.Button stop_button;

        public ProcessDialogHeaderBar(Gtk.Button stop_button, Pid pid, string app_name, string process)
        {
            this.app_name = app_name;
            this.process = process;
            show_close_button = true;
            this.stop_button = stop_button;

            stop_button.clicked.connect(() => {
                kill_process(pid);
                set_process_state(ProcessStatus.DEAD);
            });

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.hexpand = true;
            if(show_stop_button(process))
                box.pack_start(stop_button, false, false);
            label = new Gtk.Label(null);
            label.justify = Gtk.Justification.CENTER;
            box.set_center_widget(label);

            set_custom_title(box);
            show_all();
        }

        private bool show_stop_button(string process)
        {
            var settings = new GLib.Settings ("org.gnome.Usage");
            var unkillable_processes = settings.get_strv ("unkillable-processes");

            return !(process in unkillable_processes);
        }

        private void kill_process(Pid pid)
        {
            Posix.kill (pid, Posix.SIGKILL);
        }

        public void set_process_state(ProcessStatus status)
        {
            string status_string = "";
            switch(status)
            {
                case ProcessStatus.RUNNING:
                    status_string = _("Running");
                    break;
                case ProcessStatus.SLEEPING:
                    status_string = _("Sleeping");
                    break;
                case ProcessStatus.DEAD:
                    status_string = _("Dead");
                    stop_button.hide();
                    break;
            }

            this.label.set_text("<span font_weight=\"bold\">" + this.app_name + "</span>\n<span font_desc=\"8.0\">" + status_string + "</span>");
            this.label.use_markup = true;
        }
    }
}
