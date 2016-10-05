namespace Usage
{
	public class HeaderBar : Gtk.HeaderBar
	{
	    private Gtk.StackSwitcher stackSwitcher;
	    private Gtk.MenuButton menuButton;

	    public HeaderBar(Gtk.Stack stack)
	    {
	        show_close_button = true;
	        stackSwitcher = new Gtk.StackSwitcher();
            stackSwitcher.halign = Gtk.Align.CENTER;
            stackSwitcher.set_stack(stack);
            menuButton = new Gtk.MenuButton();
            menuButton.add(new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON));
	    }

	    public void setMenuButton(Gtk.Box? popoverBox)
	    {
	        var popover = new Gtk.Popover(menuButton);
	        popover.add(popoverBox);
	        menuButton.popover = popover;
	    }

	    public void showMenuButton()
        {
            pack_end(menuButton);
        }

        public void hideMenuButton()
        {
            remove(menuButton);
        }

	    public void showStackSwitcher()
        {
            set_custom_title(stackSwitcher);
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