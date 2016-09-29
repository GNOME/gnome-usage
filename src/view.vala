namespace Usage {

    public abstract class View : Gtk.Bin {

        protected SystemMonitor monitor;
        public string title;

        //public signal void mode_changed (string? title);

        /*public virtual void go_back () {
        }*/

        public View () {
            monitor = (GLib.Application.get_default () as Application).monitor;
            visible = true;
        }

		public abstract Gtk.Box? getMenuPopover();
    }
}

