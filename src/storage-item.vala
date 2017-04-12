namespace Usage
{
    public enum StorageItemPosition
    {
        FIRST,
        SECOND,
        THIRD,
        ANYWHERE,
        PENULTIMATE,
        LAST
    }

    public enum StorageItemType
    {
        STORAGE,
        SYSTEM,
        DOCUMENTS,
        DOWNLOADS,
        DESKTOP,
        MUSIC,
        PICTURES,
        VIDEOS,
        TRASH,
        TRASHFILE,
        TRASHSUBFILE,
        USER,
        AVAILABLE,
        FILE,
        DIRECTORY
    }

    public class StorageItem : Object
    {
        private string name;
        private string path;
        private StorageItemType type;
        private StorageItemType? parent;
        private uint64 size;
        private double percentage;
        private StorageItemPosition prefered_position = StorageItemPosition.ANYWHERE;
        private int section;
        private Gdk.RGBA color;

        public StorageItem.item(StorageItemType type, StorageItemType? parent, string name, string path, uint64 size, double percentage, int section = 0, StorageItemPosition prefered_position = StorageItemPosition.ANYWHERE)
        {
            this.type = type;
            this.parent = parent;
            this.name = name;
            this.path = path;
            this.size = size;
            this.percentage = percentage;
            this.section = section;
            this.prefered_position = prefered_position;
        }

        public StorageItem.directory(StorageItemType parent, string name, string path, uint64 size, double percentage)
        {
        	this.type = StorageItemType.DIRECTORY;
            this.parent = parent;
            this.name = name;
            this.path = path;
            this.size = size;
            this.percentage = percentage;
            this.section = 0;
            this.prefered_position = StorageItemPosition.ANYWHERE;
        }

        public StorageItem.file(StorageItemType parent, string name, string path, uint64 size, double percentage)
        {
            this.type = StorageItemType.FILE;
            this.parent = parent;
            this.name = name;
            this.path = path;
            this.size = size;
            this.percentage = percentage;
            this.section = 0;
            this.prefered_position = StorageItemPosition.ANYWHERE;
        }

        public StorageItem.trash(string path, uint64 size, double percentage, int section = 0)
        {
            this.type = StorageItemType.TRASH;
            this.parent = StorageItemType.TRASH;
            this.name = _("Trash");
            this.path = path;
            this.size = size;
            this.percentage = percentage;
            this.section = section;
            this.prefered_position = StorageItemPosition.PENULTIMATE;
        }

        public StorageItem.storage(string name, string path, uint64 size, int section = 0)
        {
            this.type = StorageItemType.STORAGE;
            this.parent = StorageItemType.STORAGE;
            this.name = name;
            this.path = path;
            this.size = size;
            this.percentage = 0;
            this.section = section;
            this.prefered_position = StorageItemPosition.FIRST;
        }

        public StorageItem.system(uint64 size, double percentage, int section = 0)
        {
            this.type = StorageItemType.SYSTEM;
            this.parent = StorageItemType.SYSTEM;
            this.name = _("Operating System");
            this.path = "";
            this.size = size;
            this.percentage = percentage;
            this.section = section;
            this.prefered_position = StorageItemPosition.SECOND;
        }

        public StorageItem.available(uint64 size, double percentage, int section = 0)
        {
            this.type = StorageItemType.AVAILABLE;
            this.parent = StorageItemType.AVAILABLE;
            this.name = _("Available");
            this.path = "";
            this.size = size;
            this.percentage = percentage;
            this.section = section;
            this.prefered_position = StorageItemPosition.LAST;
        }

        public StorageItemPosition get_prefered_position()
        {
            return prefered_position;
        }

        public void set_color(Gdk.RGBA color)
        {
            this.color = color;
        }

        public Gdk.RGBA get_color()
        {
            return color;
        }

        public int get_section()
        {
            return section;
        }

        public uint64 get_size()
        {
            return size;
        }

        public double get_percentage()
        {
            return percentage;
        }

        public string get_name()
        {
            return name;
        }

        public StorageItemType get_item_type()
        {
            return type;
        }

        public StorageItemType? get_parent_type()
        {
            return parent;
        }

        public string get_path()
        {
            return path;
        }
    }
}
