// project version=0.0.2

public static int main (string[] args)
{
    Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, Path.build_filename(Constants.DATADIR,"locale"));
    Intl.setlocale(LocaleCategory.ALL, "");
    Intl.textdomain(Constants.GETTEXT_PACKAGE);
    Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "utf-8");

    var application = new Usage.Application();
    return application.run(args);
}
