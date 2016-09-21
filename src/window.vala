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

            foreach (var view in UIView.all ()) {
                stack.add_titled  (views[view], views[view].name, views[view].title);
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

/*
    		var label1 = new Gtk.Label("Page 1 Content.");
    		var label5 = new Gtk.Label("Page 5 Content.");
    		var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    		paned.add1(label1);
    		paned.add2(label5);
    		stack.add_titled(paned, "page-1", "Performance");
    		var label2 = new Gtk.Label("Page 2 Content.");
    		stack.add_titled(label2, "page-2", "Data");
    		var label3 = new Gtk.Label("Page 3 Content.");
    		stack.add_titled(label3, "page-3", "Storage");
    		var label4 = new Gtk.Label("Page 4 Content.");
    		stack.add_titled(label4, "page-4", "Power");
*/

			var stack_switcher = new Gtk.StackSwitcher();
			stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.stack = stack;
            stack_switcher.set_stack(stack);

            var headerbar = new Gtk.HeaderBar();
            headerbar.show_close_button = true;
			headerbar.set_custom_title(stack_switcher);
            set_titlebar(headerbar);

            this.add(stack);
        }
    }
}
