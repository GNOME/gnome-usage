using Gee;

namespace Usage
{
    public class ProcessListBoxNew : Gtk.ListBox
    {
        ListStore model;
        HashSet<string> rows;
        string cmdline_opened_process;

        public ProcessListBoxNew()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
            row_activated.connect( (row) => {
                var process_row = (ProcessRowNew) row;
                process_row.activate();
                if(cmdline_opened_process == null)
                    cmdline_opened_process = process_row.process.cmdline;
                else
                    cmdline_opened_process = null;
            });

            rows = new HashSet<string>();
            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);

            var settings = (GLib.Application.get_default() as Application).settings;

            Timeout.add(settings.list_update_interval_UI, update);
            Timeout.add(settings.first_list_update_interval_UI, () => //First load
            {
                update();
                return false;
            });
        }

        public bool update()
        {
            foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_processes_cmdline())
            {
                if((process.cmdline in rows) == false)
                {
                    if(process.cpu_load >= 1) //TODO To backend!
                    {
                        rows.add(process.cmdline);
                        model.append(process);
                    }
                }
            }

            model.sort(sort);

            for(uint i = 0; i < model.get_n_items(); i++)
            {
                Process row = (Process) model.get_item(i);
                if(row.alive == false || row.cpu_load < 1)
                {
                    rows.remove(row.cmdline);
                    model.remove(i);
                }
            }

            return true;
        }

        public Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            bool opened = false;
            if(process.cmdline == cmdline_opened_process)
                opened = true;

            var row = new ProcessRowNew(process, opened);
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
