namespace Usage
{
    public class PerformanceView : View
    {
		/*ProcessList processListBox;
		Gtk.Label CPULoadLabel;
		List<ProcessRow> processRowList;

		bool showActiveProcess = true;*/

		Gtk.Stack performanceStack;


		public PerformanceView()
		{
            name = "PERFORMANCE";
			title = _("Performance");

            /*CPULoadLabel = new Gtk.Label(null);
            CPULoadLabel.margin_right = 100;
            var processorLabel = new Gtk.Label("<b>" + _("Processor") + "</b>");
            processorLabel.set_use_markup(true);
            var processorTextBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            processorTextBox.set_center_widget(processorLabel);
            processorTextBox.pack_end(CPULoadLabel, false, true, 0);
            processorTextBox.margin_top = 20;*/

    	    var CPUButton = new Gtk.Button.with_label("Processor");
      	    var memoryButton = new Gtk.Button.with_label("Memory");
    	    var diskButton = new Gtk.Button.with_label("Disk I/O");
    	    var networkButton = new Gtk.Button.with_label("Network");
    	    var panelBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    	    panelBox.pack_start(CPUButton, false, true, 0);
    	    panelBox.pack_start(memoryButton, false, true, 0);
    	    panelBox.pack_start(diskButton, false, true, 0);
    	    panelBox.pack_start(networkButton, false, true, 0);

		    /*processListBox = new ProcessList();

    	    var CPUBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		    var processListBoxFrame = new Gtk.Frame(null);
		    processListBoxFrame.margin_start = 100;
		    processListBoxFrame.margin_end = 100;
		    processListBoxFrame.margin_bottom = 20;
		    processListBoxFrame.add(processListBox);
		    CPUBox.pack_start(processorTextBox, false, false, 0);
		    CPUBox.pack_start(processListBoxFrame, true, false, 0);*/

		    /*var scrolledWindowCPU = new Gtk.ScrolledWindow(null, null);
		    scrolledWindowCPU.add(CPUBox);
		    scrolledWindowCPU.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);*/

		    performanceStack = new Gtk.Stack();
		    performanceStack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
    	    performanceStack.set_transition_duration(700);
    	    /*performanceStack.add_named(scrolledWindowCPU, "CPU");
    	    performanceStack.add_named(new Gtk.Label("Memory"), "RAM");
    	    performanceStack.add_named(new Gtk.Label("Disk I/O"), "DISK");
    	    performanceStack.add_named(new Gtk.Label("Network"), "NETWORK");*/

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
		    	performanceStack.set_visible_child_name("NETcpu-subview.valaWORK");
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
