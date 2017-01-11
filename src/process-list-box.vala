using Gee;

namespace Usage
{
    public enum ProcessListBoxType {
        PROCESSOR,
        MEMORY,
        NETWORK
    }

    public class ProcessListBox : Gtk.ListBox
    {
        public signal void empty();
        public signal void filled();

        ListStore model;
        ProcessRow? opened_row = null;
        string focused_row_cmdline;
        ProcessListBoxType type;

        public ProcessListBox(ProcessListBoxType type)
        {
            this.type = type;
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
            row_activated.connect((row) => {
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

            set_focus_child.connect((child) =>
            {
                if(child != null)
                {
                    focused_row_cmdline = ((ProcessRow) child).process.cmdline;
                    //GLib.stdout.printf("focused: " + focused_row_cmdline+ "\n");
                }
            });

            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);

            var settings = (GLib.Application.get_default() as Application).settings;

            Timeout.add(settings.list_update_interval_UI, update);
        }

        public bool update()
        {
            model.remove_all();

            switch(type)
            {
                default:
                case ProcessListBoxType.PROCESSOR:
                    foreach(unowned Process process in (GLib.Application.get_default() as Application).get_system_monitor().get_cpu_processes())
                        model.insert_sorted(process, sort);
                    break;
                case ProcessListBoxType.MEMORY:
                    foreach(unowned Process process in (GLib.Application.get_default() as Application).get_system_monitor().get_ram_processes())
                        model.insert_sorted(process, sort);
                    break;
                case ProcessListBoxType.NETWORK:
                    foreach(unowned Process process in (GLib.Application.get_default() as Application).get_system_monitor().get_net_processes())
                        model.insert_sorted(process, sort);
                    break;
            }

            if(model.get_n_items() == 0)
            {
                this.hide();
                empty();
            }
            else
            {
                this.show();
                filled();
            }

            return true;
        }

        private Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            bool opened = false;

            if(opened_row != null)
                if(process.cmdline == opened_row.process.cmdline)
                    opened = true;

            var row = new ProcessRow(process, type, opened);
            if(opened)
               opened_row = row;

            if(focused_row_cmdline != null)
            {
                if(process.cmdline == focused_row_cmdline)
                {
                    //row.grab_focus(); TODO not working
                    //GLib.stdout.printf("grab focus for: " + focused_row_cmdline+ "\n");
                }
            }

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
                    return (int) ((uint64) (p_a.cpu_load < p_b.cpu_load) - (uint64) (p_a.cpu_load > p_b.cpu_load));
                case ProcessListBoxType.MEMORY:
                    return (int) ((uint64) (p_a.mem_usage < p_b.mem_usage) - (uint64) (p_a.mem_usage > p_b.mem_usage));
                case ProcessListBoxType.NETWORK:
                    return (int) ((uint64) (p_a.net_all < p_b.net_all) - (uint64) (p_a.net_all > p_b.net_all));
            }
        }
    }
}
