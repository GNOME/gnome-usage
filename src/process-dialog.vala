using Gtk;
using Posix;

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/process-dialog.ui")]
	public class ProcessDialog : Gtk.Dialog
	{
	    ProcessDialogHeaderBar headerbar;
    	Pid pid;
    	string process;
        GraphBlock processor_graph_block;
        GraphBlock memory_graph_block;

        [GtkChild]
        private Gtk.Box content;

    	public ProcessDialog(Pid pid, string app_name, string process)
    	{
            Object();
    	    set_transient_for((GLib.Application.get_default() as Application).get_window());
    	    this.pid = pid;
    		this.title = app_name;
    		this.process = process;
    		create_widgets();
    	}

    	private void create_widgets()
    	{
            processor_graph_block = new GraphBlock(GraphBlockType.PROCESSOR, _("Processor"), this.title);
            memory_graph_block = new GraphBlock(GraphBlockType.MEMORY, _("Memory"), this.title);

            content.add(processor_graph_block);
            content.add(memory_graph_block);

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

            if(data != null)
            {
                app_cpu_load = (int) data.get_cpu_load();
                app_memory_usage = data.get_mem_usage();
                int processor_other = (int) monitor.x_cpu_load[data.get_last_processor()] - app_cpu_load;
                processor_other = int.max(processor_other, 0);
                processor_graph_block.update(app_cpu_load, processor_other, 100, (int) data.get_last_processor());
                process_status = data.get_status();
            }
            else
                processor_graph_block.update(0, (int) monitor.cpu_load, 100);

            memory_graph_block.update(app_memory_usage, monitor.ram_usage, monitor.ram_total);
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
