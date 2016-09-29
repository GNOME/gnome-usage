namespace Usage
{
	public enum UIView {
        /*CPU,
        MEMORY,
        DISK,
        NETWORK,*/
        PERFORMANCE,
        DATA,
        STORAGE,
        POWER,
        N_VIEWS;

        public static UIView[] all () {
            return { PERFORMANCE, DATA, STORAGE, POWER }; /*CPU, MEMORY, DISK, NETWORK,*/
        }
    }

    public class Window : Gtk.ApplicationWindow
    {
        public Window (Gtk.Application application)
        {
            GLib.Object (application: application);
            this.destroy.connect(Gtk.main_quit);

            this.set_default_size(800, 500);
            this.window_position = Gtk.WindowPosition.CENTER;

			var stack = new Gtk.Stack();
			stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
    		stack.set_transition_duration(700);


    		var views = new View[UIView.N_VIEWS];
            /*views[UIView.CPU]			= new CPUView ();
            views[UIView.MEMORY]		= new MemoryView ();
            views[UIView.DISK]			= new DiskView ();
            views[UIView.NETWORK]		= new NetworkView ();*/
            views[UIView.PERFORMANCE]	= new PerformanceView ();
            views[UIView.DATA]			= new DataView ();
            views[UIView.STORAGE]		= new StorageView ();
            views[UIView.POWER]			= new PowerView ();

			var menuButton = new Gtk.MenuButton();
			var popover = new Gtk.Popover (menuButton);

            foreach (var view in UIView.all ()) {
                stack.add_titled (views[view], views[view].name, views[view].title);
                popover.add (views[view].getMenuPopover()); //TODO fix it!!!
                /*views[view].mode_changed.connect ((title) => {
                    if (title == null) {
                        header_bar.custom_title = stack_switcher;
                        back_button.hide ();
                    } else {
                        header_bar.custom_title = null;
                        header_bar.title = title;
                        back_button.show ();
                    }
                });*/
            };

			var stackSwitcher = new Gtk.StackSwitcher();
			stackSwitcher.halign = Gtk.Align.CENTER;
            stackSwitcher.stack = stack;
            stackSwitcher.set_stack(stack);

            var headerbar = new Gtk.HeaderBar();
            headerbar.show_close_button = true;
			headerbar.set_custom_title(stackSwitcher);

            menuButton.popover = popover;
            headerbar.pack_end(menuButton);

			set_titlebar(headerbar);
            this.add(stack);
        }
    }
}
