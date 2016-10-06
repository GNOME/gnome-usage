namespace Usage
{
    public class RAMSubView : View
    {
        ProcessList process_list_box;
        Gtk.Label cpu_load_label;
        List<ProcessRow> process_row_list;
        bool show_active_process = true;

        public RAMSubView()
        {
            name = "RAM";

            cpu_load_label = new Gtk.Label(null);
            cpu_load_label.margin_right = 100;
            var processor_label = new Gtk.Label("<b>" + _("Processor") + "</b>");
            processor_label.set_use_markup(true);
            var processor_text_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            processor_text_box.set_center_widget(processor_label);
            processor_text_box.pack_end(cpu_load_label, false, true, 0);
            processor_text_box.margin_top = 20;

            process_list_box = new ProcessList();

            var cpu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_start = 100;
            process_list_box_frame.margin_end = 100;
            process_list_box_frame.margin_bottom = 20;
            process_list_box_frame.add(process_list_box);
            cpu_box.pack_start(processor_text_box, false, false, 0);
            cpu_box.pack_start(process_list_box_frame, true, false, 0);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(cpu_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            //construct_menu_button();

            add(scrolled_window);

            Timeout.add(1000, update_process);
        }

        public bool update_process()
        {
        	process_list_box.foreach((widget) => { widget.destroy(); });
            cpu_load_label.set_text(((int) monitor.cpu_load).to_string() + " %");

        	process_row_list = new List<ProcessRow>();
            foreach(unowned Process process in monitor.get_processes()) {

        	if(show_active_process)
        	{
        		if((int) process.cpu_load > 0)
        			insert_process_row(process);
        	} else
        		insert_process_row(process);
            }

            for(int i = 0; i < process_row_list.length(); i++)
            {
                process_list_box.add(process_row_list.data);
        		process_row_list =(owned) process_row_list.next;
        	}

            return true;
        }

        public void insert_process_row(Process process)
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
            popover_box.margin = 5;

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
            	monitor.update();
            	update_process();
            });

            var my = new Gtk.RadioButton.with_label_from_widget(active, _("My process"));
            popover_box.pack_start(my, false, false, 0);
            my.toggled.connect(() => {
            	show_active_process = false;
            	monitor.set_process_mode(SystemMonitor.ProcessMode.USER);
            	monitor.update();
            	update_process();
            });

            popover_box.show_all();
            header_bar.set_menu_button(popover_box);
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            //headerBar.showMenuButton();
            header_bar.show_stack_switcher();
        }
    }
}
