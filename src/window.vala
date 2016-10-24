namespace Usage
{
    public class Window : Gtk.ApplicationWindow
    {
        public static Gtk.Stack stack;
        public static Usage.HeaderBar header_bar;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);

            this.set_default_size(950, 600);
            this.set_size_request(855, 300);
            this.window_position = Gtk.WindowPosition.CENTER;

			stack = new Gtk.Stack();
			header_bar = new Usage.HeaderBar(stack);
			header_bar.show_close_button = true;

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
                visibleView.update_header_bar();
            });

            views[0].update_header_bar();
            set_titlebar(header_bar);
            this.add(stack);
        }
    }
}
