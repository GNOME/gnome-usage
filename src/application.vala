using Gtk;

namespace Usage
{
    public class Application : Gtk.Application
    {
        public Settings settings;
        private Window window;
        private SystemMonitor monitor;
        private StorageAnalyzer storage_analyzer;

        private const GLib.ActionEntry app_entries[] =
        {
          { "about", on_about },
          { "search", on_search },
          { "quit", on_quit }
        };

        public Application ()
        {
            application_id = "org.gnome.Usage";
            settings = new Settings();
            monitor = new SystemMonitor();
            storage_analyzer = new StorageAnalyzer();
        }

        public SystemMonitor get_system_monitor()
        {
            return monitor;
        }

        public StorageAnalyzer get_storage_analyzer()
        {
            return storage_analyzer;
        }

        public Window? get_window()
        {
            return window;
        }

        public override void activate()
        {
            window = new Window(this);

            // Create menu
            GLib.Menu menu_preferences = new GLib.Menu();
            GLib.Menu menu_common = new GLib.Menu();
            var item = new GLib.MenuItem (_("About"), "app.about");
            menu_common.append_item(item);

            item = new GLib.MenuItem (_("Quit"), "app.quit");
            item.set_attribute("accel", "s", "<Primary>q");
            menu_common.append_item(item);

            GLib.Menu menu = new GLib.Menu();
            menu.append_section(null, menu_preferences);
            menu.append_section(null, menu_common);

            set_app_menu(menu);
            window.show_all();
        }

        protected override void startup()
        {
            base.startup();
            add_action_entries(app_entries, this);
            set_accels_for_action ("app.search", {"<Primary>f"});
        }

        private void on_about(GLib.SimpleAction action, GLib.Variant? parameter)
        {
            string[] authors = {"Petr Štětka"};

            Gtk.show_about_dialog (window,
                program_name: _("Usage"),
                comments: _("View current application and monitor system state"),
            	authors: authors,
            	website: "https://wiki.gnome.org/Apps/Usage",
            	website_label: _("Websites"),
            	version: Config.VERSION,
            	license_type: License.GPL_3_0);
        }

        private void on_quit(GLib.SimpleAction action, GLib.Variant? parameter)
        {
            window.destroy();
        }

        private void on_search(GLib.SimpleAction action, GLib.Variant? parameter)
        {
            window.get_header_bar().action_on_search();
        }
    }
}
