[GtkTemplate (ui = "/org/gnome/Usage/ui/storage-view-row.ui")]
public class Usage.StorageViewRow : Gtk.ListBoxRow {
    public string label {
        set {
            title.label = value;
        }
        get {
            return title.label;
        }
    }

    [GtkChild]
    private Gtk.Label title;

    [GtkChild]
    public Gtk.Label size_label;

    [GtkChild]
    public Gtk.Box tag;

    public enum TagSize {
        SMALL,
        BIG,
    }
    public TagSize tag_size {
        set {
            if (value == TagSize.BIG) {
                tag.width_request = tag.height_request = 20;
            }
        }
        get {
            return (tag.width_request == 20 ? TagSize.BIG : TagSize.SMALL);
        }
    }

    public StorageViewItem item; 

    public StorageViewRow.from_item (StorageViewItem item) {
        this.item = item;

        title.label = item.name;    
        size_label.label = Utils.format_size_values (item.size);

        setup_tag_style ();
    }

    private void setup_tag_style () {
        string style_class;

        if (item.type == FileType.DIRECTORY) {
            tag.width_request = tag.height_request = 20;

            style_class = "folders";
        } else {
            style_class = "files";
        }

        if (item.dir != null) {
            switch (item.dir) {
                case UserDirectory.PICTURES:
                    style_class = "pictures";
                    break;
                case UserDirectory.VIDEOS:
                    style_class = "videos";
                    break;
                case UserDirectory.DOCUMENTS:
                    style_class = "documents";
                    break;
                case UserDirectory.MUSIC:
                    style_class = "music";
                    break;
            }
        } else {
            switch (item.ontology) {
                case "nmm#MusicPiece":
                    style_class = "music";
                    break;
                 case "nmm#Photo":
                    style_class = "pictures";
                    break;
                 case "nmm#Video":
                    style_class = "videos";
                    break;
                 case "nfo#PaginatedTextDocument":
                 case "nfo#PlainTextDocument":
                 case "nfo#FileDataObject":
                 case "nfo#EBook":
                    style_class = "documents";
                    break;
                
            }
        }

        tag.get_style_context ().add_class (style_class);
    }
}
