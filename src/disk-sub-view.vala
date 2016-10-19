namespace Usage
{
    public class DiskSubView : View
    {
        public DiskSubView()
        {
            name = "DISK";
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
