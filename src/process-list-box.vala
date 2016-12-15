using Gee;

namespace Usage
{
    public enum ProcessListBoxType {
        PROCESSOR,
        MEMORY
    }

    public class ProcessListBoxNew : Gtk.ListBox
    {
        ListStore model;
        string cmdline_opened_process;
        ProcessRow? opened_row = null;
        ProcessListBoxType type;

        public ProcessListBoxNew(ProcessListBoxType type)
        {
            this.type = type;
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
            row_activated.connect( (row) => {
                var process_row = (ProcessRow) row;

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

        private bool update()
        {
            model.remove_all();

            switch(type)
            {
                default:
                case ProcessListBoxType.PROCESSOR:
                    foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_cpu_processes())
                        model.insert_sorted(process, sort);
                    break;
                case ProcessListBoxType.MEMORY:
                    foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_ram_processes())
                        model.insert_sorted(process, sort);
                    break;
            }

            return true;
        }

        private Gtk.Widget on_row_created (Object item)
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

            var row = new ProcessRow(process, type, opened);
            if(opened)
               opened_row = row;

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
            switch(type)
            {
                default:
                case ProcessListBoxType.PROCESSOR:
                    return (int) ((Process) b).cpu_load - (int) ((Process) a).cpu_load;
                    break;
                case ProcessListBoxType.MEMORY:
                    return (int) ((Process) b).mem_usage - (int) ((Process) a).mem_usage;
                    break;
            }
        }
    }
}
