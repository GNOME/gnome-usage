namespace Usage
{
    public class Window : Gtk.ApplicationWindow
    {
        private Gtk.Stack stack;
        private Usage.HeaderBar header_bar;

		public Window(Gtk.Application application)
        {
            GLib.Object(application : application);

            this.set_default_size(950, 600);
            this.set_size_request(930, 300);
            this.window_position = Gtk.WindowPosition.CENTER;
            this.set_title(_("Usage"));

            load_css();
            Gtk.Settings.get_for_screen(get_screen()).notify["gtk-application-prefer-dark-theme"].connect(() =>
            {
                load_css();
            });

			stack = new Gtk.Stack();
			header_bar = new Usage.HeaderBar(stack);
			set_titlebar(header_bar);

			header_bar.show_close_button = true;

            var views = new View[]
            {
                new PerformanceView(),
                new DataView(),
                new StorageView(),
                new PowerView()
            };

            foreach(var view in views)
                stack.add_titled(view, view.name, view.title);

            this.add(stack);
        }

        private void load_css()
        {
            string name_css = "adwaita.css";
            var settings = Gtk.Settings.get_for_screen(get_screen());

            if(settings.gtk_application_prefer_dark_theme)
                name_css = "adwaita-dark.css";

            var provider = new Gtk.CssProvider();
            try {
                Gtk.StyleContext.reset_widgets(get_screen());
                provider.load_from_path(GLib.Path.build_filename(Constants.PKGDATADIR, name_css));
                Gtk.StyleContext.add_provider_for_screen(get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
            catch (Error e) {
                stdout.printf("Could not load CSS. %s\n", e.message);
            }
        }
    }
}
