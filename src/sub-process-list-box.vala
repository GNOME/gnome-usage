using Gee;
using Posix;

namespace Usage
{
    public class SubProcessListBox : Gtk.ListBox
    {
        ListStore model;
        Process parent_process;

        class construct
        {
            set_css_name("subprocess-list");
        }

        public SubProcessListBox(Process process)
        {
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

        public void update()
        {
           if(parent_process.sub_processes != null)
           {
               foreach(unowned Process process in parent_process.sub_processes.get_values())
               {
                   if(process.cpu_load >= 1)
                       model.append(process);
               }

               model.sort(sort);
               for(uint i = 0; i < model.get_n_items(); i++)
               {
                   Process row = (Process) model.get_item(i);
                   if(row.alive == false || row.cpu_load < 1)
                       model.remove(i);
               }
           }
        }

        public Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            var row = new SubProcessSubRow(process);
            return row;
        }

        void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
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

        public int sort(GLib.CompareDataFunc.G a, GLib.CompareDataFunc.G b)
        {
            return (int) ((Process) b).cpu_load - (int) ((Process) a).cpu_load;
        }
    }
}
