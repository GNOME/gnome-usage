namespace Usage
{
    public class MemorySubView : View
    {
        ProcessList process_list_box;
        Gtk.Label memory_load_label;
        List<ProcessRow> process_row_list;

        public MemorySubView()
        {
            name = "MEMORY";
            const int margin_side = 50;

            memory_load_label = new Gtk.Label(null);
            memory_load_label.margin_right = margin_side;
            var processor_label = new Gtk.Label("<b>" + _("Memory") + "</b>");
            processor_label.set_use_markup(true);
            var processor_text_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            processor_text_box.set_center_widget(processor_label);
            processor_text_box.pack_end(memory_load_label, false, true, 0);
            processor_text_box.margin_top = 10;
            processor_text_box.margin_bottom = 10;

            process_list_box = new ProcessList();

            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            var memory_graph = new MemoryGraph(60000, 60);
            var memory_graph_frame = new Gtk.Frame(null);
            memory_graph_frame.height_request = 200;
            memory_graph_frame.margin_start = margin_side;
            memory_graph_frame.margin_end = margin_side;
            memory_graph_frame.margin_bottom = 10;
            memory_graph_frame.add(memory_graph);

            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_start = margin_side;
            process_list_box_frame.margin_end = margin_side;
            process_list_box_frame.margin_bottom = 20;
            process_list_box_frame.add(process_list_box);
            memory_box.pack_start(processor_text_box, false, false, 0);
            memory_box.pack_start(memory_graph_frame, true, true, 0);
            memory_box.pack_start(process_list_box_frame, true, false, 0);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(memory_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);

          //  Timeout.add(1000, update_process);
        }

        private bool update_process()
        {
        	process_list_box.foreach((widget) => { widget.destroy(); });
            memory_load_label.set_text(((int) monitor.mem_usage).to_string() + " %");

        	process_row_list = new List<ProcessRow>();
            foreach(unowned Process process in monitor.get_processes())
            {
        	  	insert_process_row(process);
            }

            for(int i = 0; i < process_row_list.length(); i++)
                process_list_box.add(process_row_list.nth_data (i));

            return true;
        }

        private void insert_process_row(Process process)
        {
            var process_row = new ProcessRow(process.cmdline,(int) process.mem_usage);
            process_row.sort_id =(int)(10 * process.mem_usage);
            process_row_list.insert_sorted(process_row,(a, b) => {
            	return(b as ProcessRow).sort_id -(a as ProcessRow).sort_id;
            });
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
