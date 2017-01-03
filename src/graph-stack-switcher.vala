namespace Usage
{
    public class GraphStackSwitcher : Gtk.Box
    {
        Gtk.Stack stack;
        View[] sub_views;

        Gtk.ToggleButton[] buttons;

        bool can_change = true;

        class construct
        {
            set_css_name("graph-stack-switcher");
        }

		public GraphStackSwitcher(Gtk.Stack stack, View[] sub_views)
		{
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.stack = stack;
            this.sub_views = sub_views;

            buttons = {
                new GraphSwitcherButton.processor("Processor"),
                new GraphSwitcherButton.memory("Memory"),
                new GraphSwitcherButton.disk("Disk I/O"),
                new GraphSwitcherButton.network("Network"),
            };

    	    foreach(Gtk.ToggleButton button in buttons)
            {
                this.pack_start(button, false, true, 0);
            }

    	    buttons[0].set_active (true);

            foreach(Gtk.ToggleButton button in buttons)
            {
                button.toggled.connect (() => {
                    if(can_change)
                    {
                        if (button.active)
                        {
                            can_change = false;

                            int i = 0;
                            int button_number = 0;
                            foreach(Gtk.ToggleButton btn in buttons)
                            {
                                if(btn != button)
                                    btn.active = false;
                                else
                                    button_number = i;
                                i++;
                            }
                            this.stack.set_visible_child_name(this.sub_views[button_number].name);

                            can_change = true;
                        } else
                        {
                            can_change = false;
                            button.active = true;
                            can_change = true;
                        }
                    }
                });
            }
        }
    }
}
