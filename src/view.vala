namespace Usage
{
    public abstract class View : Gtk.Bin
    {
        protected SystemMonitor monitor;
        public string title;
        protected Usage.HeaderBar headerBar;

        public View (Usage.HeaderBar headerBar)
        {
            monitor = (GLib.Application.get_default() as Application).monitor;
            visible = true;
            this.headerBar = headerBar;
        }

		public abstract void updateHeaderBar();
    }
}
