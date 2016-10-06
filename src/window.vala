namespace Usage
{
    public class Window : Gtk.ApplicationWindow
    {
        public static Gtk.Stack stack;
        public static Usage.HeaderBar headerBar;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);

            this.set_default_size(800, 500);
            this.window_position = Gtk.WindowPosition.CENTER;

			stack = new Gtk.Stack();
			headerBar = new Usage.HeaderBar(stack);
			headerBar.show_close_button = true;

            var views =  new View[]
            {
                new PerformanceView(),
                new DataView(),
                new StorageView(),
                new PowerView()
            };

            foreach(var view in views)
                stack.add_titled(view, view.name, view.title);

            stack.notify["visible-child"].connect (() => {
                var visibleView = (View) stack.get_visible_child();
                visibleView.updateHeaderBar();
            });

            views[0].updateHeaderBar();
            set_titlebar(headerBar);
            this.add(stack);
        }
    }
}
