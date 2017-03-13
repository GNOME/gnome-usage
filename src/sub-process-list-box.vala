namespace Usage
{
    public class SubProcessListBox : Gtk.ListBox
    {
        ListStore model;
        Process parent_process;
        ProcessListBoxType type;

        class construct
        {
            set_css_name("subprocess-list");
        }

        public SubProcessListBox(Process process, ProcessListBoxType type)
        {
            this.type = type;
            parent_process = process;
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);

            row_activated.connect( (row) => {
                var sub_process_row = (SubProcessSubRow) row;
                sub_process_row.activate();
            });

            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);

            update();
        }

        private void update()
        {
           if(parent_process.get_sub_processes() != null)
           {
               foreach(unowned Process process in parent_process.get_sub_processes().get_values())
               {
                   model.insert_sorted(process, sort);
               }
           }
        }

        private Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            var row = new SubProcessSubRow(process, type);
            return row;
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
        {
            if(before_row == null)
        	    row.set_header(null);
            else
            {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
                separator.get_style_context().add_class("list");
           	    separator.show();
        	    row.set_header(separator);
        	}
        }

        private int sort(GLib.CompareDataFunc.G a, GLib.CompareDataFunc.G b)
        {
            Process p_a = (Process) a;
            Process p_b = (Process) b;

            switch(type)
            {
                default:
                case ProcessListBoxType.PROCESSOR:
                    return (int) ((uint64) (p_a.get_cpu_load() < p_b.get_cpu_load()) - (uint64) (p_a.get_cpu_load() > p_b.get_cpu_load()));
                case ProcessListBoxType.MEMORY:
                    return (int) ((uint64) (p_a.get_mem_usage() < p_b.get_mem_usage()) - (uint64) (p_a.get_mem_usage() > p_b.get_mem_usage()));
                case ProcessListBoxType.NETWORK:
                    return (int) ((uint64) (p_a.get_net_all() < p_b.get_net_all()) - (uint64) (p_a.get_net_all() > p_b.get_net_all()));
            }
        }
    }
}
