namespace Usage {

    public class PerformanceView : View {

        public PerformanceView () {
            name = "performance";
            title = _("Performance");

            var label1 = new Gtk.Label("Page 1 Content.");
    		var label2 = new Gtk.Label("Page 2 Content.");
    		string processList = "";
    		var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    		paned.add1(label1);
    		paned.add2(label2);
			add(paned);

			Timeout.add (1000, () => {

                label1.set_text ("%d%%".printf ((int) (monitor.cpu_load * 100)));


				processList = "";
                foreach (unowned Process process in monitor.get_processes ()) {
                    var load = process.cpu_load * 100;
                    if(load > 0)
                    	processList += "\n" + process.cmdline + "\t" + load.to_string();
                    label2.set_text(processList);
                }

                return true;
            });
        }
    }
}
