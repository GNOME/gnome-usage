namespace Usage
{
    public abstract class View : Gtk.Bin
    {
        protected SystemMonitor monitor;
        public string title;
        protected Usage.HeaderBar header_bar;

        public View ()
        {
            monitor = (GLib.Application.get_default() as Application).monitor;
            header_bar = (GLib.Application.get_default() as Application).window.header_bar;
            visible = true;
        }

		public abstract void update_header_bar();

    }
}
