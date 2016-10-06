namespace Usage
{
    public class PerformanceView : View
    {
        Gtk.Stack performance_stack;

		public PerformanceView()
		{
            name = "PERFORMANCE";
			title = _("Performance");

    	    var cpu_button = new Gtk.Button.with_label("Processor");
      	    var memory_button = new Gtk.Button.with_label("Memory");
    	    var disk_button = new Gtk.Button.with_label("Disk I/O");
    	    var network_button = new Gtk.Button.with_label("Network");
    	    var panel_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    	    panel_box.pack_start(cpu_button, false, true, 0);
    	    panel_box.pack_start(memory_button, false, true, 0);
    	    panel_box.pack_start(disk_button, false, true, 0);
    	    panel_box.pack_start(network_button, false, true, 0);

		    performance_stack = new Gtk.Stack();
		    performance_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
    	    performance_stack.set_transition_duration(700);

    	    var sub_views =  new View[]
            {
                new CPUSubView(),
                new RAMSubView()
            };

            foreach(var sub_view in sub_views)
                performance_stack.add_named(sub_view, sub_view.name);

    	    cpu_button.clicked.connect(() => {
		    	performance_stack.set_visible_child_name(sub_views[0].name);
                ((View) performance_stack.get_visible_child()).update_header_bar();
		    });
		    memory_button.clicked.connect(() => {
		    	performance_stack.set_visible_child_name(sub_views[1].name);
		    	((View) performance_stack.get_visible_child()).update_header_bar();
		    });
		    disk_button.clicked.connect(() => {
		    	performance_stack.set_visible_child_name("DISK");
		    	header_bar.hide_menu_button();
		    });
		    network_button.clicked.connect(() => {
		    	performance_stack.set_visible_child_name("NETWORK");
		    	header_bar.hide_menu_button();
		    });

    	    var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    	    paned.add1(panel_box);
    	    paned.add2(performance_stack);
		    add(paned);
        }

        public override void update_header_bar()
        {
            var visible_sub_view = (View) performance_stack.get_visible_child();
            visible_sub_view.update_header_bar();
        }
    }
}
