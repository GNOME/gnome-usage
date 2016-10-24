using Better;
namespace Usage
{
    public class MemorySubView : View
    {
        ProcessList process_list_box;
        Gtk.Label memory_load_label;
        List<ProcessRow> process_row_list;
        bool show_active_process = true;

        public MemorySubView()
        {
            name = "MEMORY";

            memory_load_label = new Gtk.Label(null);
            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Memory") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 20;
            label.margin_bottom = 15;

            process_list_box = new ProcessList();

            var memory_graph = new MemoryGraph();
            var memory_graph_frame = new Gtk.Frame(null);
            memory_graph_frame.height_request = 225;
            memory_graph_frame.width_request = 600;
            memory_graph_frame.valign = Gtk.Align.START;
            memory_graph_frame.add(memory_graph);

            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_top = 30;
            process_list_box_frame.add(process_list_box);
            
            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            memory_box.pack_start(label, false, false, 0);
            memory_box.pack_start(memory_graph_frame, false, false, 0);
            memory_box.pack_start(process_list_box_frame, false, false, 0);

            var better_box = new Better.Box();
            better_box.max_width_request = 600;
            better_box.halign = Gtk.Align.CENTER;
            better_box.orientation = Gtk.Orientation.HORIZONTAL;
            better_box.add(memory_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);

            Timeout.add(1000, update_process);
        }

        //TODO better management
        private bool update_process()
        {
        	process_list_box.foreach((widget) => { widget.destroy(); });
            memory_load_label.set_text(((int) monitor.mem_usage).to_string() + " %");

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
