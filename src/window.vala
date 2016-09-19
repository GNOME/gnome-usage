namespace Usage
{
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
