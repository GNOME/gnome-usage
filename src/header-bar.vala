namespace Usage
{
    public enum HeaderBarMode
    {
        PERFORMANCE,
        DATA,
        STORAGE,
        POWER
    }

	public class HeaderBar : Gtk.HeaderBar
	{
	    private Gtk.StackSwitcher stack_switcher;
	    private Gtk.Button? storage_back_button;
	    private bool show_storage_back_btn = false;
	    private Gtk.Button? storage_rescan_button;
	    private HeaderBarMode mode;

	    public HeaderBar(Gtk.Stack stack)
	    {
	        mode = HeaderBarMode.PERFORMANCE;
	        show_close_button = true;
	        stack_switcher = new Gtk.StackSwitcher();
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.set_stack(stack);

            set_mode(HeaderBarMode.PERFORMANCE);
            show_all();
	    }

	    public void set_mode(HeaderBarMode mode)
	    {
            switch(this.mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    break;
                case HeaderBarMode.DATA:
                    break;
                case HeaderBarMode.STORAGE:
                    remove(storage_back_button);
                    remove(storage_rescan_button);
                    storage_rescan_button = null;
                    storage_back_button = null;
                    break;
                case HeaderBarMode.POWER:
                    break;
            }

            switch(mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    show_stack_switcher();
                    break;
                case HeaderBarMode.DATA:
                    show_stack_switcher();
                    break;
                case HeaderBarMode.STORAGE:
                    show_stack_switcher();
                    storage_back_button = new Gtk.Button.from_icon_name("go-previous-symbolic");
                    storage_back_button.clicked.connect(() => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().on_back_button_clicked();
                    });
                    show_storage_back_button(show_storage_back_btn);
                    storage_rescan_button = new Gtk.Button.from_icon_name("view-refresh-symbolic");
                    storage_rescan_button.clicked.connect(() => {
                        (GLib.Application.get_default() as Application).get_storage_analyzer().create_cache.begin(true);
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().reload();
                    });
                    storage_rescan_button.show();
                    pack_start(storage_back_button);
                    pack_end(storage_rescan_button);
                    break;
                case HeaderBarMode.POWER:
                    show_stack_switcher();
                    break;
            }
            this.mode = mode;
	    }

	    public void show_title_text(string title)
	    {
	        set_custom_title(null);
            set_title(title);
	    }

	    public void show_stack_switcher()
        {
            set_custom_title(stack_switcher);
        }

        public void show_storage_back_button(bool show)
        {
            if(storage_back_button != null)
            {
                if(show)
                {
                    storage_back_button.show();
                    show_storage_back_btn = true;
                }
                else
                {
                    storage_back_button.hide();
                    show_storage_back_btn = false;
                }
            }

        }
	}
}