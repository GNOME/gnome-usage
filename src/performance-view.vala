using Gtk;

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/performance-view.ui")]
    public class PerformanceView : View
    {
        [GtkChild]
        private Gtk.Box switcher_box;

        [GtkChild]
        private Gtk.Stack performance_stack;

        [GtkChild]
        private Gtk.SearchBar search_bar;

        [GtkChild]
        private Gtk.SearchEntry search_entry;

        View[] sub_views;

        public PerformanceView ()
        {
            name = "PERFORMANCE";
            title = _("Performance");

            sub_views = new View[]
            {
                new ProcessorSubView(),
                new MemorySubView()
            };

            foreach(var sub_view in sub_views)
                performance_stack.add_titled(sub_view, sub_view.name, sub_view.name);

		    var stackSwitcher = new GraphStackSwitcher(performance_stack, sub_views);
            switcher_box.add (stackSwitcher);

            show_all ();
        }

        [GtkCallback]
        private void on_search_entry_changed () {
            foreach(View sub_view in sub_views)
                ((SubView) sub_view).search_in_processes(search_entry.get_text());
        }

        public void set_search_mode(bool enable)
        {
            search_bar.set_search_mode(enable);
        }
    }
}
