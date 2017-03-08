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
        string search_text = "";

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
                    if(process_row.process.get_sub_processes() != null)
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
                    focused_row_cmdline = ((ProcessRow) child).process.get_cmdline();
                    //GLib.stdout.printf("focused: " + focused_row_cmdline+ "\n");
                }
            });

            model = new ListStore(typeof(Process));
            bind_model(model, on_row_created);

            var settings = (GLib.Application.get_default() as Application).settings;

            uint update_interval;
            switch(type)
            {
                default:
                case ProcessListBoxType.PROCESSOR:
                case ProcessListBoxType.MEMORY:
                    update_interval = settings.list_update_interval_UI;
                    break;
                case ProcessListBoxType.NETWORK:
                    update_interval = settings.list_update_interval_UI_often;
                    break;
            }
            Timeout.add(update_interval, update);
        }

        public bool update()
        {
            bind_model(null, null);
            model.remove_all();

            if(search_text == "")
            {
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
            }
            else
            {
                foreach(unowned Process process in (GLib.Application.get_default() as Application).get_system_monitor().get_ram_processes()) //because ram contains all processes
                {
                    if(process.get_cmdline().down().contains(search_text.down())) //TODO Search in DisplayName too
                        model.insert_sorted(process, sort);
                }
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

            bind_model(model, on_row_created);
            return true;
        }

        public void search(string text)
        {
            search_text = text;
            update();
        }

        private Gtk.Widget on_row_created (Object item)
        {
            Process process = (Process) item;
            bool opened = false;

            if(opened_row != null)
                if(process.get_cmdline() == opened_row.process.get_cmdline())
                    opened = true;

            var row = new ProcessRow(process, type, opened);
            if(opened)
               opened_row = row;

            if(focused_row_cmdline != null)
            {
                if(process.get_cmdline() == focused_row_cmdline)
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
                    return (int) ((uint64) (p_a.get_cpu_load() < p_b.get_cpu_load()) - (uint64) (p_a.get_cpu_load() > p_b.get_cpu_load()));
                case ProcessListBoxType.MEMORY:
                    return (int) ((uint64) (p_a.get_mem_usage() < p_b.get_mem_usage()) - (uint64) (p_a.get_mem_usage() > p_b.get_mem_usage()));
                case ProcessListBoxType.NETWORK:
                    return (int) ((uint64) (p_a.get_net_all() < p_b.get_net_all()) - (uint64) (p_a.get_net_all() > p_b.get_net_all()));
            }
        }
    }
}
