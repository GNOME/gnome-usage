public static int main (string[] args)
{
    // messon
    Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.setlocale(LocaleCategory.ALL, "");
    Intl.textdomain(Config.GETTEXT_PACKAGE);
    Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");

    //Autovala
    /*Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, Path.build_filename(Constants.DATADIR,"locale"));
    Intl.setlocale(LocaleCategory.ALL, "");
    Intl.textdomain(Constants.GETTEXT_PACKAGE);
    Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "utf-8");*/

    var application = new Usage.Application();
    return application.run(args);
}
