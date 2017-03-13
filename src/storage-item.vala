namespace Usage
{
    public enum StorageItemPosition
    {
        FIRST,
        SECOND,
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
        private uint64 size;
        private double percentage;
        private StorageItemPosition prefered_position = StorageItemPosition.ANYWHERE;
        private int section;
        private Gdk.RGBA color;

        public StorageItem.item(StorageItemType type, string name, string path, uint64 size, double percentage, int section = 0, StorageItemPosition prefered_position = StorageItemPosition.ANYWHERE)
        {
            this.type = type;
            this.name = name;
            this.path = path;
            this.size = size;
            this.percentage = percentage;
            this.section = section;
            this.prefered_position = prefered_position;
        }

        public StorageItem.directory(string name, string path, uint64 size, double percentage)
        {
            StorageItem.item(StorageItemType.DIRECTORY, name, path, size, percentage);
        }

        public StorageItem.file(string name, string path, uint64 size, double percentage)
        {
            StorageItem.item(StorageItemType.FILE, name, path, size, percentage);
        }

        public StorageItem.trash(string path, uint64 size, double percentage, int section = 0)
        {
            StorageItem.item(StorageItemType.TRASH, _("Trash"), path, size, percentage, section, StorageItemPosition.PENULTIMATE);
        }

        public StorageItem.storage(string name, string path, uint64 size, int section = 0)
        {
            StorageItem.item(StorageItemType.STORAGE, name, path, size, 0, section, StorageItemPosition.FIRST);
        }

        public StorageItem.system(string name, uint64 size, double percentage, int section = 0)
        {
            StorageItem.item(StorageItemType.SYSTEM, name, "", size, percentage, section);
        }

        public StorageItem.available(uint64 size, double percentage, int section = 0)
        {
            StorageItem.item(StorageItemType.AVAILABLE, _("Available"), "", size, percentage, section, StorageItemPosition.LAST);
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

        public string get_path()
        {
            return path;
        }
    }
}