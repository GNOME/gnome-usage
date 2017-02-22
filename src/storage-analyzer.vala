using GTop;

namespace Usage
{
    public class StorageAnalyzer : Object
    {
        public signal void cache_complete();
        public bool cache { private set; get; }
        public bool separate_home = false;

        private Cancellable cancellable;
        private HashTable<string, Directory?> directory_table;
        private HashTable<string, Storage?> storages;
        private AsyncQueue<StorageResult> results_queue;
        private string[] exclude_from_home;
        private static bool path_null;

        private struct Directory
        {
            public uint64 size;
            public float percentage;
        }

        private struct Storage
        {
            public uint64 used;
            public uint64 free;
            public uint64 total;
            public string name;
            public string mount_path;
        }

        private Storage? get_storage(string mount_path)
        {
            return storages[mount_path];
        }

        private Directory? get_directory(string path)
        {
            return directory_table[path];
        }

        public void stop_scanning()
        {
            cancellable.cancel();
        }

        public async List<StorageItem> prepare_items(string? path, Gdk.RGBA color)
        {
            if(path == null)
            {
                path_null = true;
                List<StorageItem> items = new List<StorageItem>();

                if(separate_home)
                {
                    Storage? home = get_storage("/home");
                    items.insert_sorted(new StorageItem.storage(_("Storage 1"), home.mount_path, home.total, 0), (CompareFunc) sort);
                    add_home_items(ref items, 0);
                    items.insert_sorted(new StorageItem.available(home.free, ((float) home.free / home.total) * 100, 0), (CompareFunc) sort);
                    Storage? root = get_storage("/");
                    items.insert_sorted(new StorageItem.storage(_("Storage 2"), root.mount_path, root.total, 1), (CompareFunc) sort);
                    add_root_items(ref items, root, 1);
                    items.insert_sorted(new StorageItem.available(root.free, ((float) root.free / root.total) * 100, 1), (CompareFunc) sort);
                }
                else
                {
                    Storage? root = get_storage("/");
                    items.insert_sorted(new StorageItem.storage(_("Storage 1"), root.mount_path, root.total, 0), (CompareFunc) sort);
                    add_root_items(ref items, root, 0);
                    add_home_items(ref items, 0);
                    items.insert_sorted(new StorageItem.available(root.free, ((float) root.free / root.total) * 100), (CompareFunc) sort);
                }

                set_colors(ref items, color);
                return items;
            } else
            {
                path_null = false;
                return get_items_for_path(path, color, exclude_from_home);
            }
        }

        private static int sort(StorageItem a, StorageItem b)
        {
            if(a.get_section() > b.get_section())
                return 1;
            else if (a.get_section() < b.get_section())
                return -1;
            else
            {
                switch(a.get_prefered_position())
                {
                    case StorageItemPosition.FIRST:
                        return -1;
                    case StorageItemPosition.SECOND:
                        if(b.get_prefered_position() != StorageItemPosition.FIRST)
                            return -1;
                        else
                            return 1;
                    case StorageItemPosition.ANYWHERE:
                        switch(b.get_prefered_position())
                        {
                            case StorageItemPosition.FIRST:
                                return 1;
                            case StorageItemPosition.SECOND:
                                return 1;
                            case StorageItemPosition.ANYWHERE:
                                if(path_null == true)
                                    return sort_alphabetically(a.get_name(), b.get_name());
                                else
                                    return (int) ((uint64) (a.get_size() < b.get_size()) - (uint64) (a.get_size() > b.get_size()));
                            case StorageItemPosition.PENULTIMATE:
                                return -1;
                            case StorageItemPosition.LAST:
                                return -1;
                        }
                        break;
                    case StorageItemPosition.PENULTIMATE:
                        if(b.get_prefered_position() != StorageItemPosition.LAST)
                            return 1;
                        else
                            return -1;
                    case StorageItemPosition.LAST:
                        return 1;
                }
            }

            return 0;
        }

        private static int sort_alphabetically(string first, string second)
        {
            int length = first.length < second.length ? first.length : second.length;
            for(int i = 0; i < length; i++)
            {
                if(first[i] < second[i])
                    return -1;
                else if(first[i] > second[i])
                    return 1;
            }
            return first.length < second.length ? -1 : 1;
        }

        private void set_colors(ref List<StorageItem> items, Gdk.RGBA default_color)
        {
            for(int i = 0; i < items.length(); i++)
            {
                unowned StorageItem item = items.nth_data(i);
                switch(item.get_item_type())
                {
                    case StorageItemType.DOCUMENTS:
                    case StorageItemType.DOWNLOADS:
                    case StorageItemType.DESKTOP:
                    case StorageItemType.MUSIC:
                    case StorageItemType.PICTURES:
                    case StorageItemType.VIDEOS:
                        item.set_color(generate_color(default_color, i-2, 6, false)); //6 because DOCUMENTS, DOWNLOADS, DESKTOP, MUSIC, PICTURES, VIDEOS, 2 because header and Home
                        break;
                    case StorageItemType.DIRECTORY:
                    case StorageItemType.FILE:
                        item.set_color(generate_color(default_color, i, items.length(), true));
                        break;
                }
            }
        }

        private Gdk.RGBA generate_color(Gdk.RGBA default_color, int order, uint all_color, bool reverse = false)
        {
            order += 1;

            double step = 100 / all_color;
            if(all_color % 2 == 1)
            {
                if((all_color / 2) + 1 == order)
                    return default_color;
                else
                    step = 100 / (all_color - 1);
            }

            if(order > (all_color / 2))
            {
                if(all_color % 2 == 1)
                    order -= 1;
                double percentage = step * (order - (all_color/2));
                if(reverse)
                    return Utils.color_lighter(default_color, percentage);
                else
                    return Utils.color_darker(default_color, percentage);
            }
            else
            {
                double percentage = step * ((all_color/2) - (order-1));
                if(reverse)
                    return Utils.color_darker(default_color, percentage);
                else
                    return Utils.color_lighter(default_color, percentage);
            }
        }

        public async void create_cache(bool force_override = false)
        {
            if(force_override == true)
               cache = false;

            if(cache == false)
            {
                cache = true;
                analyze_storages();
                stop_scanning();
                cancellable.reset();
                directory_table.remove_all();
                SourceFunc callback = create_cache.callback;

                ThreadFunc<void*> run = () => {
                    scan_cache();
                    Idle.add((owned) callback);
                    return null;
                };

                var thread = new Thread<void*>("storage_analyzer", run);
                yield;
                thread.join();
                cache_complete();
            }
        }

        private void scan_cache()
        {
            uint64 total_size;
            if(separate_home)
            {
                Storage? home = get_storage("/home");
                total_size = home.total;
            }
            else
            {
                Storage? root = get_storage("/");
                total_size = root.total;
            }

            var desktop   = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DESKTOP)), total_size, ref cancellable, ref results_queue);
            var documents = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DOCUMENTS)), total_size, ref cancellable, ref results_queue);
            var downloads = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DOWNLOAD)), total_size, ref cancellable, ref results_queue);
            var music     = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.MUSIC)), total_size, ref cancellable, ref results_queue);
            var pictures  = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.PICTURES)), total_size, ref cancellable, ref results_queue);
            var videos    = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.VIDEOS)), total_size, ref cancellable, ref results_queue);
            var trash     = new StorageWorker(File.new_for_path(Environment.get_home_dir() + "/.local/share/Trash/files"), total_size, ref cancellable, ref results_queue, _("Trash"));
            var home      = new StorageWorker(File.new_for_path(Environment.get_home_dir()), total_size, ref cancellable, ref results_queue, Environment.get_real_name(), exclude_from_home);

            try {
                ThreadPool<StorageWorker> threads = new ThreadPool<StorageWorker>.with_owned_data((worker) => {
                    worker.run();
                }, (int) get_num_processors(), false);

                threads.add(home);
                threads.add(desktop);
                threads.add(documents);
                threads.add(downloads);
                threads.add(music);
                threads.add(pictures);
                threads.add(videos);
                threads.add(trash);
            }
            catch (ThreadError e)
            {
                stderr.printf("%s", e.message);
            }

            StorageResult result;
            while ((result = results_queue.try_pop()) != null)
            {
                var directory = Directory();
                directory.size = result.size;
                directory.percentage = result.percentage;
                directory_table.insert (result.path, directory);
            }
        }

        private void add_root_items(ref List<StorageItem> items, Storage storage, int section)
        {
            items.insert_sorted(new StorageItem.system(_("Operation System"), storage.used, ((float) storage.free / storage.total) * 100, section), (CompareFunc) sort);
        }

        private void add_home_items(ref List<StorageItem> items, int section)
        {
            Directory? user = get_directory(Environment.get_home_dir());
            if(user != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.USER,
                    _("Home"),
                    Environment.get_home_dir(),
                    user.size,
                    user.percentage,
                    section,
                    StorageItemPosition.SECOND), (CompareFunc) sort);
            }
            Directory? desktop = get_directory(Environment.get_user_special_dir(UserDirectory.DESKTOP));
            if(desktop != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DESKTOP,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DESKTOP)),
                    Environment.get_user_special_dir(UserDirectory.DESKTOP),
                    desktop.size,
                    desktop.percentage,
                    section), (CompareFunc) sort);
            }
            Directory? documents = get_directory(Environment.get_user_special_dir(UserDirectory.DOCUMENTS));
            if(documents != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DOCUMENTS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DOCUMENTS)),
                    Environment.get_user_special_dir(UserDirectory.DOCUMENTS),
                    documents.size,
                    documents.percentage,
                    section), (CompareFunc) sort);
            }
            Directory? downloads = get_directory(Environment.get_user_special_dir(UserDirectory.DOWNLOAD));
            if(downloads != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DOWNLOADS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DOWNLOAD)),
                    Environment.get_user_special_dir(UserDirectory.DOWNLOAD),
                    downloads.size,
                    downloads.percentage,
                    section), (CompareFunc) sort);
            }
            Directory? music = get_directory(Environment.get_user_special_dir(UserDirectory.MUSIC));
            if(music != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.MUSIC,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.MUSIC)),
                    Environment.get_user_special_dir(UserDirectory.MUSIC),
                    music.size,
                    music.percentage,
                    section), (CompareFunc) sort);
            }
            Directory? pictures = get_directory(Environment.get_user_special_dir(UserDirectory.PICTURES));
            if(pictures != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.PICTURES,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.PICTURES)),
                    Environment.get_user_special_dir(UserDirectory.PICTURES),
                    pictures.size,
                    pictures.percentage,
                    section), (CompareFunc) sort);
            }
            Directory? videos = get_directory(Environment.get_user_special_dir(UserDirectory.VIDEOS));
            if(videos != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.VIDEOS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.VIDEOS)),
                    Environment.get_user_special_dir(UserDirectory.VIDEOS),
                    videos.size,
                    videos.percentage,
                    section), (CompareFunc) sort);
            }
            var trash_path = Environment.get_home_dir() + "/.local/share/Trash/files";
            Directory? trash = get_directory(trash_path);
            if(trash != null)
            {
                items.insert_sorted(new StorageItem.trash(
                    trash_path,
                    trash.size,
                    trash.percentage,
                    section), (CompareFunc) sort);
            }
        }

        private List<StorageItem> get_items_for_path(string path, Gdk.RGBA color, string[]? exclude_paths = null)
        {
            List<StorageItem> items = new List<StorageItem>();

            File file = File.new_for_path(path);
            FileEnumerator enumerator;

            try {
                enumerator = file.enumerate_children(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null && cancellable.is_cancelled() == false)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        if(exclude_paths == null || !(file.resolve_relative_path(info.get_name()).get_path() in exclude_paths))
                        {
                            string folder_path = file.get_child(info.get_name()).get_parse_name();
                            Directory? folder = get_directory(folder_path);
                            uint64 folder_size = 0;
                            double folder_percentage = 0;

                            if(folder != null)
                            {
                                folder_size = folder.size;
                                folder_percentage = folder.percentage;
                            }

                            items.insert_sorted(new StorageItem.directory(info.get_name(), folder_path, folder_size,
                                folder_percentage), (CompareFunc) sort);
                        }
                    }
                    else if(info.get_file_type() == FileType.REGULAR)
                    {
                        Directory? parent = get_directory(path);
                        float percentage = ((float) info.get_size() / parent.size) * 100;

                        items.insert_sorted(new StorageItem.file(info.get_name(),
                            file.get_child(info.get_name()).get_parse_name(), info.get_size(), percentage),
                            (CompareFunc) sort);
                    }
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            set_colors(ref items, color);

            return items;
        }

        private void analyze_storages()
        {
            separate_home = false;
            storages.remove_all();

            MountList mount_list;
            MountEntry[] entries = GTop.get_mountlist(out mount_list, false);

            for (int i = 0; i < mount_list.number; i++)
            {
                string mountdir = (string) entries[i].mountdir;
                if(mountdir == "/" || mountdir == "/home")
                {
                    if(mountdir == "/home")
                        separate_home = true;

                    FsUsage root;
                    GTop.get_fsusage(out root, mountdir);

                    Storage storage = Storage();
                    storage.free = root.bfree * root.block_size;
                    storage.total = root.blocks * root.block_size;
                    storage.used = storage.total - storage.free;
                    storage.name = (string) entries[i].devname;
                    storage.mount_path = mountdir;
                    storages.insert (mountdir, storage);
                }
            }
        }

        public StorageAnalyzer()
        {
            cache = false;
            cancellable = new Cancellable();
            directory_table = new HashTable<string, Directory?>(str_hash, str_equal);
            storages = new HashTable<string, Storage?>(str_hash, str_equal);
            results_queue = new AsyncQueue<StorageResult>();
            exclude_from_home = {
                Environment.get_user_special_dir(UserDirectory.DESKTOP),
                Environment.get_user_special_dir(UserDirectory.DOCUMENTS),
                Environment.get_user_special_dir(UserDirectory.DOWNLOAD),
                Environment.get_user_special_dir(UserDirectory.MUSIC),
                Environment.get_user_special_dir(UserDirectory.PICTURES),
                Environment.get_user_special_dir(UserDirectory.VIDEOS),
                Environment.get_home_dir() + "/.local/share/Trash/files"
            };
        }
    }
}