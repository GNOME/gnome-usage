namespace Usage
{
    public class Window : Gtk.ApplicationWindow
    {
        private Usage.HeaderBar header_bar;
        private View[] views;

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

			var stack = new Gtk.Stack();
			header_bar = new Usage.HeaderBar(stack);
			set_titlebar(header_bar);

            views = new View[]
            {
                new PerformanceView(),
                new DataView(),
                new StorageView(),
                new PowerView()
            };

            foreach(var view in views)
                stack.add_titled(view, view.name, view.title);

            stack.notify.connect(() => {
                if(stack.visible_child_name == views[0].name)
                {
                    header_bar.set_mode(HeaderBarMode.PERFORMANCE);
                }
                else if(stack.visible_child_name == views[1].name)
                {
                    header_bar.set_mode(HeaderBarMode.DATA);
                }
                else if(stack.visible_child_name == views[2].name)
                {
                    header_bar.set_mode(HeaderBarMode.STORAGE);
                    (GLib.Application.get_default() as Application).get_storage_analyzer().create_cache.begin();
                }
                else if(stack.visible_child_name == views[3].name)
                {
                    header_bar.set_mode(HeaderBarMode.POWER);
                }
            });

            this.add(stack);
        }

        public Usage.HeaderBar get_header_bar()
        {
            return header_bar;
        }

        public View[] get_views()
        {
            return views;
        }

        private void load_css()
        {
            string name_css = "adwaita.css";
            var settings = Gtk.Settings.get_for_screen(get_screen());

            if(settings.gtk_application_prefer_dark_theme)
                name_css = "adwaita-dark.css";

            var provider = new Gtk.CssProvider();
            Gtk.StyleContext.reset_widgets(get_screen());
            provider.load_from_resource("/org/gnome/Usage/interface/" + name_css);
            Gtk.StyleContext.add_provider_for_screen(get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
