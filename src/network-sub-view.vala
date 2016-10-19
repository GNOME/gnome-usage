namespace Usage
{
    public class NetworkSubView : View
    {
        public NetworkSubView()
        {
            name = "NETWORK";
        }

        public override void update_header_bar()
        {
            header_bar.clear();
            header_bar.show_stack_switcher();
        }
    }
}
