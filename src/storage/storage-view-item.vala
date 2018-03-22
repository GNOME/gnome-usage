public class Usage.StorageViewItem : GLib.Object {
    public Gdk.Color color;

    public int percentage { set; get; default = 5; } // FIXME 

    public string uri;
    public string name;
    public uint64 size;

    public FileType type;
    public UserDirectory? dir;
    public string ontology;

    public StorageViewItem.from_file (File file) {
        uri = file.get_uri ();

        var info = file.query_info (FileAttribute.STANDARD_SIZE + "," + FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE + "," + FileAttribute.TRASH_ORIG_PATH, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

        name = info.get_name ();
        size = info.get_size ();
        type = info.get_file_type ();
    }
}
