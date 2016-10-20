using Gtk;

namespace Usage
{
    public class Application : Gtk.Application
    {
        public Settings settings;
        public Window window;
        public SystemMonitor monitor;

        public Application ()
        {
            application_id = "org.gnome.usage";
            settings = new Settings();
            monitor = new SystemMonitor();
        }

        public override void activate()
        {
            window = new Window(this);
            window.show_all();
        }
    }
}
