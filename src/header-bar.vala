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
	    private bool active_performance_search_btn = false;
	    private Gtk.Button? storage_back_button;
	    private Gtk.Button? storage_rescan_button;
	    private Gtk.Button? storage_select_button;
	    private Gtk.Button? storage_cancel_button;
	    private Gtk.MenuButton? storage_selection_menu;
	    private bool show_storage_back_btn = false;
	    private bool show_storage_rescan_btn = false;
	    private bool show_storage_select_btn = false;
	    private string title_text = "";
	    private HeaderBarMode mode;

	    const GLib.ActionEntry[] select_action_entries = {
           { "select-all", select_all },
           { "select-none", select_none },
        };

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
                    remove_widget(storage_select_button);
                    remove_widget(storage_cancel_button);
                    storage_rescan_button = null;
                    storage_back_button = null;
                    storage_select_button = null;
                    storage_select_button = null;
                    storage_cancel_button = null;
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
                    performance_search_button.set_active(active_performance_search_btn);
                    performance_search_button.toggled.connect(() => {
                        active_performance_search_btn = performance_search_button.active;
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
                        show_storage_select_button(false);
                        show_storage_rescan_button(false);
                        show_storage_back_button(false);
                        (GLib.Application.get_default() as Application).get_storage_analyzer().create_cache.begin(true);
                        ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().reload();
                    });

                    storage_select_button = new Gtk.Button.from_icon_name("emblem-ok-symbolic");
                    storage_select_button.clicked.connect(() => {
                        show_storage_selection_mode(true);
                    });
                    show_storage_select_button(show_storage_select_btn);
                    show_storage_rescan_button(show_storage_rescan_btn);

                    storage_cancel_button = new Gtk.Button.with_label(_("Cancel"));
                    storage_cancel_button.clicked.connect(() => {
                        show_storage_selection_mode(false);
                    });

                    pack_start(storage_back_button);
                    pack_end(storage_select_button);
                    pack_end(storage_rescan_button);
                    pack_end(storage_cancel_button);
                    break;
                case HeaderBarMode.POWER:
                    show_stack_switcher();
                    break;
            }
            this.mode = mode;
	    }

	    public void change_selected_items(uint count)
	    {
	        if(storage_selection_menu != null)
	        {
	            if(count > 0)
                    storage_selection_menu.label = ngettext ("%u selected", "%u selected", count).printf (count);
                else
                    storage_selection_menu.label = _("Click on items to select them");
	        }
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

        public void show_storage_select_button(bool show)
        {
            if(show)
            {
                if(storage_select_button != null)
                    storage_select_button.show();
                show_storage_select_btn = true;
            }
            else
            {
                if(storage_select_button != null)
                    storage_select_button.hide();
                show_storage_select_btn = false;
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

        public void show_storage_selection_mode(bool show)
        {
            if(show)
            {
                show_storage_rescan_button(false);
                show_storage_select_button(false);
                storage_back_button.hide();
                storage_cancel_button.show();
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).show_action_bar(true);
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().set_select_mode(true);

                var menu = new GLib.Menu ();
                var item = new GLib.MenuItem (_("Select all"), "headerbar.select-all");
                item.set_attribute("accel", "s", "<Primary>a");
                menu.append_item(item);

                item = new GLib.MenuItem (_("Select None"), "headerbar.select-none");
                menu.append_item(item);

                storage_selection_menu = new Gtk.MenuButton();
                storage_selection_menu.get_style_context().add_class("selection-menu");
                storage_selection_menu.set_menu_model(menu);

                var action_group = new GLib.SimpleActionGroup ();
                action_group.add_action_entries (select_action_entries, this);
                storage_selection_menu.get_popover().insert_action_group ("headerbar", action_group);

                storage_selection_menu.show();
                set_custom_title(storage_selection_menu);
                change_selected_items(0);

                this.get_style_context().add_class("selection-mode");
                this.show_close_button = false;
            }
            else
            {
                if(show_storage_back_btn)
                    storage_back_button.show();

                show_storage_rescan_button(true);
                show_storage_select_button(true);
                storage_cancel_button.hide();
                storage_selection_menu = null;
                if(title_text == "")
                    show_stack_switcher();
                else
                    show_title();
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).show_action_bar(false);
                ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().set_select_mode(false);
                this.get_style_context().remove_class("selection-mode");
                this.show_close_button = true;
            }
        }

        private void select_all()
        {
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().select_all_rows();

        }

        private void select_none()
        {
            ((StorageView) (GLib.Application.get_default() as Application).get_window().get_views()[2]).get_storage_list_box().unselect_all_rows();
        }

        private void remove_widget(Gtk.Widget? widget)
        {
            if(widget != null)
                remove(widget);
        }
	}
}