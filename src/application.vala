using Gtk;

namespace Usage {

    public class Application : Gtk.Application {

        private Window window;

        public Application () {
            application_id = "org.gnome.usage";
        }

        public override void activate () {
            window = new Window (this);
            window.show_all();
        }
    }
}
