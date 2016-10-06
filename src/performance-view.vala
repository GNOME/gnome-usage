namespace Usage
{
    public class PerformanceView : View
    {
        Gtk.Stack performanceStack;

		public PerformanceView()
		{
            name = "PERFORMANCE";
			title = _("Performance");

    	    var CPUButton = new Gtk.Button.with_label("Processor");
      	    var memoryButton = new Gtk.Button.with_label("Memory");
    	    var diskButton = new Gtk.Button.with_label("Disk I/O");
    	    var networkButton = new Gtk.Button.with_label("Network");
    	    var panelBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    	    panelBox.pack_start(CPUButton, false, true, 0);
    	    panelBox.pack_start(memoryButton, false, true, 0);
    	    panelBox.pack_start(diskButton, false, true, 0);
    	    panelBox.pack_start(networkButton, false, true, 0);

		    performanceStack = new Gtk.Stack();
		    performanceStack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
    	    performanceStack.set_transition_duration(700);

    	    var subViews =  new View[]
            {
                new CPUsubView(),
                new RAMsubView()
            };

            foreach(var subView in subViews)
                performanceStack.add_named(subView, subView.name);

    	    CPUButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name(subViews[0].name);
                ((View) performanceStack.get_visible_child()).updateHeaderBar();
		    });
		    memoryButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name(subViews[1].name);
		    	((View) performanceStack.get_visible_child()).updateHeaderBar();
		    });
		    diskButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("DISK");
		    	headerBar.hideMenuButton();
		    });
		    networkButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("NETWORK");
		    	headerBar.hideMenuButton();
		    });

    	    var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    	    paned.add1(panelBox);
    	    paned.add2(performanceStack);
		    add(paned);
        }

        public override void updateHeaderBar()
        {
            var visibleSubView = (View) performanceStack.get_visible_child();
            visibleSubView.updateHeaderBar();
        }
    }
}
