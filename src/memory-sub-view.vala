using Better;
namespace Usage
{
    public class MemorySubView : View
    {
        Gtk.Label memory_load_label;
        bool show_active_process = true;

        public MemorySubView()
        {
            name = "MEMORY";

            memory_load_label = new Gtk.Label(null);
            var label = new Gtk.Label("<span font_desc=\"14.0\">" + _("Memory") + "</span>");
            label.set_use_markup(true);
            label.margin_top = 20;
            label.margin_bottom = 15;

            var memory_graph = new MemoryGraph();
            var memory_graph_frame = new Gtk.Frame(null);
            memory_graph_frame.height_request = 225;
            memory_graph_frame.width_request = 600;
            memory_graph_frame.valign = Gtk.Align.START;
            memory_graph_frame.add(memory_graph);

            var process_list_box_frame = new Gtk.Frame(null);
            process_list_box_frame.margin_top = 30;

            var memory_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            memory_box.pack_start(label, false, false, 0);
            memory_box.pack_start(memory_graph_frame, false, false, 0);
            memory_box.pack_start(process_list_box_frame, false, false, 0);

            var better_box = new Better.Box();
            better_box.max_width_request = 600;
            better_box.halign = Gtk.Align.CENTER;
            better_box.orientation = Gtk.Orientation.HORIZONTAL;
            better_box.add(memory_box);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(better_box);
            scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            add(scrolled_window);
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
