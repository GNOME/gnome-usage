namespace Usage
{
    public class GraphStackSwitcher : Gtk.Box
    {
        Gtk.Stack stack;
        View[] sub_views;

        Gtk.ToggleButton cpu_button;
        Gtk.ToggleButton memory_button;
        Gtk.ToggleButton disk_button;
        Gtk.ToggleButton network_button;

        bool can_change = true;

		public GraphStackSwitcher(Gtk.Stack stack, View[] sub_views)
		{
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.stack = stack;
            this.sub_views = sub_views;

            cpu_button = new GraphSwitcherButton.processor("Processor");
            memory_button = new GraphSwitcherButton.memory("Memory");
            disk_button = new GraphSwitcherButton.disk("Disk I/O");
            network_button = new GraphSwitcherButton.network("Network");

    	    this.pack_start(cpu_button, false, true, 0);
    	    this.pack_start(memory_button, false, true, 0);
    	    this.pack_start(disk_button, false, true, 0);
    	    this.pack_start(network_button, false, true, 0);

    	    cpu_button.set_active (true);

    	    cpu_button.clicked.connect (() => {
    	        if(can_change)
    	        {
                    if (cpu_button.active)
                    {
                        can_change = false;

                        memory_button.active = false;
                        disk_button.active = false;
                        network_button.active = false;

                        this.stack.set_visible_child_name(this.sub_views[0].name);
                        ((View) this.stack.get_visible_child()).update_header_bar();

                        can_change = true;
                    } else
                    {
                        can_change = false;
                        cpu_button.active = true;
                        can_change = true;
                    }
    	        }

            });

            memory_button.clicked.connect (() => {
                if(can_change)
                {
                    if (memory_button.active)
                    {
                        can_change = false;

                        cpu_button.active = false;
                        disk_button.active = false;
                        network_button.active = false;

                        this.stack.set_visible_child_name(this.sub_views[1].name);
                        ((View) this.stack.get_visible_child()).update_header_bar();

                        can_change = true;
                    } else
                    {
                        can_change = false;
                        memory_button.active = true;
                        can_change = true;
                    }
                }
            });

            disk_button.clicked.connect (() => {
                if(can_change)
                {
                    if (disk_button.active)
                    {
                        can_change = false;

                        cpu_button.active = false;
                        memory_button.active = false;
                        network_button.active = false;

                        this.stack.set_visible_child_name(this.sub_views[2].name);
                        ((View) this.stack.get_visible_child()).update_header_bar();

                        can_change = true;
                    } else
                    {
                        can_change = false;
                        disk_button.active = true;
                        can_change = true;
                    }
                }
            });

            network_button.clicked.connect (() => {
                if(can_change)
                {
                    if (network_button.active)
                    {
                        can_change = false;

                        cpu_button.active = false;
                        memory_button.active = false;
                        disk_button.active = false;

                        this.stack.set_visible_child_name(this.sub_views[3].name);
                        ((View) this.stack.get_visible_child()).update_header_bar();

                        can_change = true;
                    } else
                    {
                        can_change = false;
                        network_button.active = true;
                        can_change = true;
                    }
                }
            });
        }
    }
}
