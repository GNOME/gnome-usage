namespace Usage {

    public class PowerView : View {

        public PowerView () {
            name = "POWER";
            title = _("Power");

            var label1 = new Gtk.Label("Page 1 Content.");
			add(label1);
        }

        public override Gtk.Box? getMenuPopover() {
			return null;
        }
    }
}
