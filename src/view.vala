namespace Usage
{
    public abstract class View : Gtk.Bin
    {
        protected SystemMonitor monitor;
        public string title;

        public View ()
        {
            monitor = (GLib.Application.get_default() as Application).get_system_monitor();
            visible = true;
        }
    }

    public interface SubView {
        public abstract void search_in_processes(string text);
    }
}
