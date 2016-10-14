using Gtk;

namespace Usage
{
    public class Application : Gtk.Application
    {
        public Window window;
        public SystemMonitor monitor;

        public Application ()
        {
            application_id = "org.gnome.usage";
            monitor = new SystemMonitor(1000);
        }

        public override void activate()
        {
            window = new Window(this);
            window.show_all();
        }
    }
}
