namespace Usage
{
    public abstract class View : Gtk.Bin
    {
        protected SystemMonitor monitor;
        public string title;
        protected Usage.HeaderBar headerBar;

        public View ()
        {
            monitor = (GLib.Application.get_default() as Application).monitor;
            headerBar = (GLib.Application.get_default() as Application).window.headerBar;
            visible = true;
        }

		public abstract void updateHeaderBar();

    }
}
