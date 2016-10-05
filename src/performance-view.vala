namespace Usage
{
    public class PerformanceView : View
    {
		ProcessList processListBox;
		Gtk.Label CPULoadLabel;
		List<ProcessRow> processRowList;

		bool showActiveProcess = true;

		public PerformanceView(Usage.HeaderBar headerBar)
		{
		    base(headerBar);

            name = "PERFORMANCE";
			title = _("Performance");

            CPULoadLabel = new Gtk.Label(null);
            CPULoadLabel.margin_right = 100;
            var processorLabel = new Gtk.Label("<b>" + _("Processor") + "</b>");
            processorLabel.set_use_markup(true);
            var processorTextBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            processorTextBox.set_center_widget(processorLabel);
            processorTextBox.pack_end(CPULoadLabel, false, true, 0);
            processorTextBox.margin_top = 20;

    	    var CPUButton = new Gtk.Button.with_label("Processor");
      	    var memoryButton = new Gtk.Button.with_label("Memory");
    	    var diskButton = new Gtk.Button.with_label("Disk I/O");
    	    var networkButton = new Gtk.Button.with_label("Network");
    	    var panelBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    	    panelBox.pack_start(CPUButton, false, true, 0);
    	    panelBox.pack_start(memoryButton, false, true, 0);
    	    panelBox.pack_start(diskButton, false, true, 0);
    	    panelBox.pack_start(networkButton, false, true, 0);

		    processListBox = new ProcessList();

    	    var CPUBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		    var processListBoxFrame = new Gtk.Frame(null);
		    processListBoxFrame.margin_start = 100;
		    processListBoxFrame.margin_end = 100;
		    processListBoxFrame.margin_bottom = 20;
		    processListBoxFrame.add(processListBox);
		    CPUBox.pack_start(processorTextBox, false, false, 0);
		    CPUBox.pack_start(processListBoxFrame, true, false, 0);

		    var scrolledWindowCPU = new Gtk.ScrolledWindow(null, null);
		    scrolledWindowCPU.add(CPUBox);
		    scrolledWindowCPU.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

		    var performanceStack = new Gtk.Stack();
		    performanceStack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
    	    performanceStack.set_transition_duration(700);
    	    performanceStack.add_named(scrolledWindowCPU, "CPU");
    	    performanceStack.add_named(new Gtk.Label("Memory"), "RAM");
    	    performanceStack.add_named(new Gtk.Label("Disk I/O"), "DISK");
    	    performanceStack.add_named(new Gtk.Label("Network"), "NETWORK");

    	    CPUButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("CPU");
                constructMenuButtonForCPU();
                headerBar.showMenuButton();
		    });
		    memoryButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("RAM");
		    	headerBar.hideMenuButton();
		    });
		    diskButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("DISK");
		    	headerBar.hideMenuButton();
		    });
		    networkButton.clicked.connect(() => {
		    	performanceStack.set_visible_child_name("NETWORK");
		    	headerBar.hideMenuButton();
		    });

		    constructMenuButtonForCPU();

    	    var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    	    paned.add1(panelBox);
    	    paned.add2(performanceStack);
		    add(paned);

		    Timeout.add(1000, updateProcess);
        }

        public bool updateProcess()
        {
        	processListBox.foreach((widget) => { widget.destroy(); });
            CPULoadLabel.set_text(((int) monitor.cpu_load).to_string() + " %");

			processRowList = new List<ProcessRow>();
            foreach(unowned Process process in monitor.get_processes()) {

			if(showActiveProcess)
			{
				if((int) process.cpu_load > 0)
					insertProcessRow(process);
			} else
				insertProcessRow(process);
            }

            for(int i = 0; i < processRowList.length(); i++)
            {
                processListBox.add(processRowList.data);
				processRowList =(owned) processRowList.next;
			}

            return true;
        }

        public void insertProcessRow(Process process)
        {
            var processRow = new ProcessRow(process.cmdline,(int) process.cpu_load);
            processRow.sortId =(int)(10 * process.cpu_load);
            processRowList.insert_sorted(processRow,(a, b) => {
            	return(b as ProcessRow).sortId -(a as ProcessRow).sortId;
            });
        }

        private void constructMenuButtonForCPU()
        {
        	var popoverBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            popoverBox.margin = 5;

            var active = new Gtk.RadioButton.with_label_from_widget(null, _("Active process"));
            popoverBox.pack_start(active, false, false, 0);
            active.toggled.connect(() => {
            	monitor.setProcessMode(SystemMonitor.ProcessMode.ALL);
            	showActiveProcess = true;
            	updateProcess();
            });

            var all = new Gtk.RadioButton.with_label_from_widget(active, _("All process"));
            popoverBox.pack_start(all, false, false, 0);
            all.toggled.connect(() => {
            	showActiveProcess = false;
            	monitor.setProcessMode(SystemMonitor.ProcessMode.ALL);
            	monitor.update();
            	updateProcess();
            });

            var my = new Gtk.RadioButton.with_label_from_widget(active, _("My process"));
            popoverBox.pack_start(my, false, false, 0);
            my.toggled.connect(() => {
            	showActiveProcess = false;
            	monitor.setProcessMode(SystemMonitor.ProcessMode.USER);
            	monitor.update();
            	updateProcess();
            });

            popoverBox.show_all();
            headerBar.setMenuButton(popoverBox);
        }

        public override void updateHeaderBar()
        {
            headerBar.clear();
            headerBar.showMenuButton();
            headerBar.showStackSwitcher();
        }
    }
}
