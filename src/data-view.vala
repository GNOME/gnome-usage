namespace Usage {

    public class DataView : View {

        public DataView () {
            name = "DATA";
            title = _("Data");

            var label1 = new Gtk.Label("Page 1 Content.");
			add(label1);
        }
    }
}
