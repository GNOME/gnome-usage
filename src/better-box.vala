namespace Usage {

    public class BetterBox : Gtk.Box
    {
        public int max_width_request { get; set;  default = -1; }

        private new void get_preferred_width(out int minimum_width, out int natural_width)
        {
            int min_width;
            int nat_width;
            get_preferred_width(out min_width, out nat_width);

            if (max_width_request > 0)
            {
                if (min_width > max_width_request)
                    min_width = max_width_request;

                if (nat_width > max_width_request)
                    nat_width = max_width_request;
            }
        }
    }
}
