using Gee;

namespace Usage
{
    public class ProcessListBoxNew : Gtk.ListBox
    {
        ListStore model;
        string cmdline_opened_process;
        ProcessRowNew? opened_row = null;

        public ProcessListBoxNew()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
            row_activated.connect( (row) => {
                var process_row = (ProcessRowNew) row;

                if(opened_row != null)
                    opened_row.activate();

                if(opened_row != process_row)
                {
                    process_row.activate();
                    if(process_row.process.sub_processes != null)
                        opened_row = process_row;
                    else
                        opened_row = null;
                }
                else
                    opened_row = null;
            });

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
            model.remove_all();

            foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_processes_cmdline())
                model.insert_sorted(process, sort);

            return true;
        }

        public Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            bool opened = false;

            if(opened_row != null)
            {
                if(process.cmdline == opened_row.process.cmdline)
                {
                    opened = true;
                }
            }

            var row = new ProcessRowNew(process, opened);
            if(opened)
               opened_row = row;

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
