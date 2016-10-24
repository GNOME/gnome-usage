[CCode (cprefix = "Better", gir_namespace = "Better", gir_version = "1.0", lower_case_cprefix = "better_")]
namespace Better {
	[CCode (cheader_filename = "better-box.h", type_id = "better_box_get_type ()")]
	public class Box : Gtk.Box, Atk.Implementor, Gtk.Buildable, Gtk.Orientable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public Box ();
		public int get_max_width_request ();
		public void set_max_width_request (int max_width_request);
		public int max_width_request { get; set; }
	}
}