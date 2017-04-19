namespace Usage
{
    public class PerformanceView : View
    {
        Gtk.Stack performance_stack;
        Gtk.SearchBar search_bar;
        View[] sub_views;

		public PerformanceView()
		{
            name = "PERFORMANCE";
			title = _("Performance");

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            sub_views = new View[]
            {
                new ProcessorSubView(),
                new MemorySubView()
            };

            search_bar = new Gtk.SearchBar();
            var search_entry = new Gtk.SearchEntry();
            search_entry.width_request = 350;
            search_entry.search_changed.connect(() => {
                foreach(View sub_view in sub_views)
                    ((SubView) sub_view).search_in_processes(search_entry.get_text());
            });
            search_bar.add(search_entry);
            search_bar.connect_entry(search_entry);

            performance_stack = new Gtk.Stack();
            performance_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN);
            performance_stack.set_transition_duration(700);
            performance_stack.vexpand = true;

            box.add(search_bar);
            box.add(performance_stack);

            foreach(var sub_view in sub_views)
                performance_stack.add_titled(sub_view, sub_view.name, sub_view.name);

		    var stackSwitcher = new GraphStackSwitcher(performance_stack, sub_views);
		    stackSwitcher.set_size_request(200, -1);
		    stackSwitcher.get_style_context().add_class("sidebar");

    	    var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    	    paned.add1(stackSwitcher);
    	    paned.add2(box);
		    add(paned);
        }

        public void set_search_mode(bool enable)
        {
            search_bar.set_search_mode(enable);
        }
    }
}
