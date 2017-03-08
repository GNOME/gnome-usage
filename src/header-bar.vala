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
	    private Gtk.ToggleButton? performance_search_button;
	    private Gtk.Button? storage_back_button;
	    private Gtk.Button? storage_rescan_button;
	    private bool show_storage_back_btn = false;
	    private bool show_storage_rescan_btn = false;
	    private string title_text = "";
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
                    remove_widget(performance_search_button);
                    performance_search_button = null;
                    break;
                case HeaderBarMode.DATA:
                    break;
                case HeaderBarMode.STORAGE:
                    remove_widget(storage_back_button);
                    remove_widget(storage_rescan_button);
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
                    performance_search_button = new Gtk.ToggleButton();
                    performance_search_button.set_image(new Gtk.Image.from_icon_name("system-search-symbolic", Gtk.IconSize.BUTTON));
                    performance_search_button.toggled.connect(() => {
                        ((PerformanceView) (GLib.Application.get_default() as Application).get_window().get_views()[0]).set_search_mode(performance_search_button.active);
                    });
                    performance_search_button.show();
                    pack_end(performance_search_button);
                    break;
                case HeaderBarMode.DATA:
                    show_stack_switcher();
                    break;
                case HeaderBarMode.STORAGE:
                    if(title_text == "")
                        show_stack_switcher();
                    else
                        show_title();
                    storage_back_button = new Gtk.Button.from_icon_name("go-previous-symbolic");
                    storage_back_button.clicked.connect(() => {
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().on_back_button_clicked();
                    });
                    show_storage_back_button(show_storage_back_btn);

                    storage_rescan_button = new Gtk.Button.from_icon_name("view-refresh-symbolic");
                    storage_rescan_button.clicked.connect(() => {
                        show_stack_switcher();
                        show_storage_rescan_button(false);
                        show_storage_back_button(false);
                        (GLib.Application.get_default() as Application).get_storage_analyzer().create_cache.begin(true);
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().reload();
                    });
                    show_storage_rescan_button(show_storage_rescan_btn);

                    pack_start(storage_back_button);
                    pack_end(storage_rescan_button);
                    break;
                case HeaderBarMode.POWER:
                    show_stack_switcher();
                    break;
            }
            this.mode = mode;
	    }

	    private void remove_widget(Gtk.Widget? widget)
	    {
            if(widget != null)
                remove(widget);
	    }

	    public HeaderBarMode get_mode()
	    {
	        return mode;
	    }

	    public void show_title()
	    {
	        set_custom_title(null);
            set_title(title_text);
	    }

	    public void set_title_text(string title)
        {
            this.title_text = title;
        }

	    public void show_stack_switcher()
        {
            set_custom_title(stack_switcher);
        }

        public void show_storage_back_button(bool show)
        {
            if(show)
            {
                if(storage_back_button != null)
                    storage_back_button.show();
                show_storage_back_btn = true;
            }
            else
            {
                if(storage_back_button != null)
                    storage_back_button.hide();
                show_storage_back_btn = false;
            }
        }

        public void show_storage_rescan_button(bool show)
        {
            if(show)
            {
                if(storage_rescan_button != null)
                    storage_rescan_button.show();
                show_storage_rescan_btn = true;
            }
            else
            {
                if(storage_rescan_button != null)
                    storage_rescan_button.hide();
                show_storage_rescan_btn = false;
            }
        }

        public void action_on_search()
        {
            switch(mode)
            {
                case HeaderBarMode.PERFORMANCE:
                    performance_search_button.set_active(!performance_search_button.get_active());
                    break;
                case HeaderBarMode.DATA:
                case HeaderBarMode.STORAGE:
                case HeaderBarMode.POWER:
                    break;
            }
        }
	}
}