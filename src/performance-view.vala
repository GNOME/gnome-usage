namespace Usage
{
    public class PerformanceView : View
    {
        Gtk.Stack performance_stack;

		public PerformanceView()
		{
            name = "PERFORMANCE";
			title = _("Performance");

            performance_stack = new Gtk.Stack();
            performance_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
            performance_stack.set_transition_duration(700);

    	    var sub_views = new View[]
            {
                new ProcessorSubView(),
                new MemorySubView(),
                new DiskSubView(),
                new NetworkSubView()
            };

            foreach(var sub_view in sub_views)
                performance_stack.add_titled(sub_view, sub_view.name, sub_view.name);

		    var stackSwitcher = new GraphStackSwitcher(performance_stack, sub_views);

    	    var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    	    paned.add1(stackSwitcher);
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
