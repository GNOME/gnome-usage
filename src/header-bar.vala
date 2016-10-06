namespace Usage
{
	public class HeaderBar : Gtk.HeaderBar
	{
	    private Gtk.StackSwitcher stack_switcher;
	    private Gtk.MenuButton menu_button;

	    public HeaderBar(Gtk.Stack stack)
	    {
	        show_close_button = true;
	        stack_switcher = new Gtk.StackSwitcher();
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.set_stack(stack);
            menu_button = new Gtk.MenuButton();
            menu_button.add(new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON));
	    }

	    public void set_menu_button(Gtk.Box? popover_box)
	    {
	        var popover = new Gtk.Popover(menu_button);
	        popover.add(popover_box);
	        menu_button.popover = popover;
	    }

	    public void show_menu_button()
        {
            pack_end(menu_button);
        }

        public void hide_menu_button()
        {
            remove(menu_button);
        }

	    public void show_stack_switcher()
        {
            set_custom_title(stack_switcher);
        }

	    public void clear()
	    {
            set_custom_title(null);

            var children = get_children ();
            foreach (Gtk.Widget child in children)
                remove(child);
	    }
	}
}