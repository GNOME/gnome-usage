using Gtk;

namespace Usage
{
    public class Application : Gtk.Application
    {
        private Window window;
        public SystemMonitor monitor;

        public Application ()
        {
            application_id = "org.gnome.usage";
            monitor = new SystemMonitor();
        }

        public override void activate()
        {
            window = new Window(this);
            window.show_all();
        }
    }
}
