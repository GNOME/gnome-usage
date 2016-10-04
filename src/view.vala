namespace Usage
{
    public abstract class View : Gtk.Bin
    {
        protected SystemMonitor monitor;
        public string title;

        public View ()
        {
            monitor = (GLib.Application.get_default() as Application).monitor;
            visible = true;
        }

		public abstract Gtk.Box? getMenuPopover();
    }
}
