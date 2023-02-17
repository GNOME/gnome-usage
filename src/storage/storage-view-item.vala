/* storage-view-item.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Felipe Borges <felipeborges@gnome.org>
 *          Petr Štětka <pstetka@redhat.com>
 */

public enum Usage.StorageViewType {
    NONE,
    OS,
    UP_FOLDER,
    AVAILABLE_GRAPH,
    ROOT_ITEM;
}

public class Usage.StorageViewItem : GLib.Object {
    public double percentage { get; set; }
    public bool loaded { get; set; default = false; }
    public Gdk.RGBA color { get; set; }

    public string uri;
    public string name;
    public uint64 size;

    public FileType type;
    public UserDirectory? dir;
    public string ontology;
    public StorageViewType custom_type = StorageViewType.NONE;

    private string _style_class = null;
    public string style_class {
        get {
            if (_style_class != null)
                return _style_class;

            setup_tag_style ();

            return _style_class;
        }
        protected set {
            _style_class = value;
        }
    }

    public bool show_check_button {
        get {
           return _show_check_button ();
        }
    }

    public static StorageViewItem? from_file (File file) {
        var item = new StorageViewItem ();
        item.uri = file.get_uri ();

        try {
            var info = file.query_info (FileAttribute.STANDARD_SIZE + "," + FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE + "," + FileAttribute.TRASH_ORIG_PATH, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            item.name = info.get_name ();
            item.size = info.get_size ();
            item.type = info.get_file_type ();
        } catch (GLib.Error error) {
            return null;
        }

        return item;
    }

    private void setup_tag_style () {
        if (type == FileType.DIRECTORY) {
            style_class = "folders";
        }

        if (dir != null) {
            switch (dir) {
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
                case UserDirectory.DOWNLOAD:
                    style_class = "downloads";
                    break;
                default:
                    break;
            }
        }

        switch (ontology) {
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
             default:
                break;
        }

        if (custom_type != StorageViewType.NONE) {
            switch (custom_type) {
                case StorageViewType.OS:
                    style_class = "os-tag";
                    break;
                case StorageViewType.AVAILABLE_GRAPH:
                    style_class = "available-tag";
                    break;
                default:
                    break;
            }
        }

        if (_style_class == null)
            style_class = "files";
    }

    private bool _show_check_button () {
        if (custom_type != StorageViewType.NONE) {
            switch (custom_type) {
                case StorageViewType.OS:
                case StorageViewType.AVAILABLE_GRAPH:
                case StorageViewType.UP_FOLDER:
                    return false;
                default:
                    break;
            }
        }

        if (dir != null) {
            switch (dir) {
                case UserDirectory.PICTURES:
                case UserDirectory.VIDEOS:
                case UserDirectory.DOCUMENTS:
                case UserDirectory.MUSIC:
                case UserDirectory.DOWNLOAD:
                    return true;
                default:
                    break;
            }
        }

        switch (ontology) {
            case "nmm#MusicPiece":
            case "nmm#Photo":
            case "nmm#Video":
            case "nfo#PaginatedTextDocument":
            case "nfo#PlainTextDocument":
            case "nfo#FileDataObject":
            case "nfo#EBook":
                return true;
            default:
                break;
        }

        return false;
    }

    public Gdk.RGBA get_base_color () {
        Gdk.RGBA base_color = Gdk.RGBA ();
        switch (style_class) {
            case "available-tag":
                base_color.parse ("#ffffff");
                break;
            case "os-tag":
                base_color.parse ("#000000");
                break;
            case "folders":
                base_color.parse ("#737373");
                break;
            case "downloads":
                base_color.parse ("#ffe451");
                break;
            case "pictures":
                base_color.parse ("#2493d3");
                break;
            case "videos":
                base_color.parse ("#a77aa5");
                break;
            case "documents":
                base_color.parse ("#7be95a");
                break;
            case "music":
                base_color.parse ("#f9a14a");
                break;
            case "files":
            default:
                base_color.parse ("#cdcdcd");
                break;
        }
        return base_color;
    }
}
