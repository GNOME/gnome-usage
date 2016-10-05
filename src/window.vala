namespace Usage
{
    public class Window : Gtk.ApplicationWindow
    {
        Gtk.Stack stack;
        Usage.HeaderBar headerBar;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);
            this.destroy.connect(Gtk.main_quit);

            this.set_default_size(800, 500);
            this.window_position = Gtk.WindowPosition.CENTER;

			stack = new Gtk.Stack();
			headerBar = new Usage.HeaderBar(stack);
			headerBar.show_close_button = true;

            var views =  new View[]
            {
                new PerformanceView(headerBar),
                new DataView(headerBar),
                new StorageView(headerBar),
                new PowerView(headerBar)
            };

            foreach(var view in views)
                stack.add_titled(view, view.name, view.title);

            stack.notify["visible-child"].connect (() => {
                View visibleView = (View) stack.get_visible_child();
                visibleView.updateHeaderBar();
            });

            views[0].updateHeaderBar();
            set_titlebar(headerBar);
            this.add(stack);
        }
    }
}
