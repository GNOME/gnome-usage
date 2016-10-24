namespace Usage
{
    public class ProcessorSubView : View
    {
        ProcessList process_list_box;
        Gtk.Label cpu_load_label;
        List<ProcessRow> process_row_list;
        bool show_active_process = true;

        public ProcessorSubView()
        {
            name = "PROCESSOR";

            cpu_load_label = new Gtk.Label(null);
            var label =  new Gtk.Label("<span font_desc=\"14.0\">" + _("Processor") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 20;
            label.margin_bottom = 15;

            process_list_box = new ProcessList();

            var cpu_graph = new CpuGraphMulti();
            var cpu_graph_frame = new Gtk.Frame(null);
            cpu_graph_frame.height_request = 225;
            cpu_graph_frame.width_request = 600;
            cpu_graph_frame.valign = Gtk.Align.START;
            cpu_graph_frame.add(cpu_graph);

            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_top = 30;
            process_list_box_frame.add(process_list_box);

            var cpu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            cpu_box.pack_start(label, false, false, 0);
            cpu_box.pack_start(cpu_graph_frame, false, false, 0);
            cpu_box.pack_start(process_list_box_frame, false, false, 0);

            var better_box = new Better.Box();
            better_box.max_width_request = 600;
            better_box.halign = Gtk.Align.CENTER;
            better_box.orientation = Gtk.Orientation.HORIZONTAL;
            better_box.add(cpu_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            construct_menu_button();

            add(scrolled_window);

            Timeout.add(1000, update_process);
        }

        //TODO better management
        private bool update_process()
        {
        	process_list_box.foreach((widget) => { widget.destroy(); });
            cpu_load_label.set_text(((int) monitor.cpu_load).to_string() + " %");

        	process_row_list = new List<ProcessRow>();
            foreach(unowned Process process in monitor.get_processes())
            {
        	    if(show_active_process)
        	    {
        	    	if((int) process.cpu_load > 0)
        	    		insert_process_row(process);
        	    }
        	    else
        	    	insert_process_row(process);
            }

            for(int i = 0; i < process_row_list.length(); i++)
                process_list_box.add(process_row_list.nth_data (i));

            return true;
        }

        private void insert_process_row(Process process)
        {
            var process_row = new ProcessRow(process.cmdline,(int) process.cpu_load);
            process_row.sort_id =(int)(10 * process.cpu_load);
            process_row_list.insert_sorted(process_row,(a, b) => {
            	return(b as ProcessRow).sort_id -(a as ProcessRow).sort_id;
            });
        }

        private void construct_menu_button()
        {
        	var popover_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            popover_box.margin = 7;

            var active = new Gtk.RadioButton.with_label_from_widget(null, _("Active process"));
            popover_box.pack_start(active, false, false, 0);
            active.toggled.connect(() => {
            	monitor.set_process_mode(SystemMonitor.ProcessMode.ALL);
            	show_active_process = true;
            	update_process();
            });

            var all = new Gtk.RadioButton.with_label_from_widget(active, _("All process"));
            popover_box.pack_start(all, false, false, 0);
            all.toggled.connect(() => {
            	show_active_process = false;
            	monitor.set_process_mode(SystemMonitor.ProcessMode.ALL);
            	monitor.update_data();
            	update_process();
            });

            var my = new Gtk.RadioButton.with_label_from_widget(active, _("My process"));
            popover_box.pack_start(my, false, false, 0);
            my.toggled.connect(() => {
            	show_active_process = false;
            	monitor.set_process_mode(SystemMonitor.ProcessMode.USER);
            	monitor.update_data();
            	update_process();
            });

            popover_box.show_all();
            header_bar.set_menu_button(popover_box);
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_menu_button();
            header_bar.show_stack_switcher();
        }
    }
}
