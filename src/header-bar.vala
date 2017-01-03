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
            set_custom_title(stack_switcher);
            menu_button = new Gtk.MenuButton();
            menu_button.add(new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON));
            show_all();
	    }
	}
}