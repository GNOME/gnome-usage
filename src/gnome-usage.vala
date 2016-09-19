// project version=0.0.1

public static int main (string[] args) {

    Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, Path.build_filename(Constants.DATADIR,"locale"));
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.textdomain(Constants.GETTEXT_PACKAGE);
    Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "utf-8");

    stdout.printf ("Not Translatable string");
    stdout.printf (_("Translatable string!"));

    var application = new Usage.Application ();
    return application.run (args);
}
