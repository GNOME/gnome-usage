using GTop;

namespace Usage
{
    public class StorageAnalyzer : Object
    {
        public signal void cache_complete();
        public bool cache { private set; get; }

        private bool separate_home = false;
        private Cancellable cancellable;
        private HashTable<string, uint64?> directory_size_table;
        private HashTable<string, Storage?> storages;
        private string[] exclude_from_home;
        private static bool path_null;
        private bool can_scan = true;
        private const string TRASH_PATH = "trash:///";
        private const string file_attributes = FileAttribute.STANDARD_SIZE + "," + FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE;

        private enum Operation
        {
            PLUS,
            MINUS
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

        private uint64? get_size_of_directory(string path)
        {
            return directory_size_table[path];
        }

        public void stop_scanning()
        {
            cancellable.cancel();
        }

        public bool get_separate_home()
        {
            return separate_home;
        }

        public async List<StorageItem> prepare_items(string? path, Gdk.RGBA color, StorageItemType? parent)
        {
            if(path == null)
            {
                path_null = true;
                List<StorageItem> items = new List<StorageItem>();

                if(separate_home)
                {
                    Storage? home = get_storage("/home");
                    items.insert_sorted(new StorageItem.storage(_("Storage 1"), home.mount_path, home.total, 0), (CompareFunc) sort);
                    add_home_items(ref items, home, 0);
                    items.insert_sorted(new StorageItem.available(home.free, ((float) home.free / home.total) * 100, 0), (CompareFunc) sort);
                    Storage? root = get_storage("/");
                    items.insert_sorted(new StorageItem.storage(_("Storage 2"), root.mount_path, root.total, 1), (CompareFunc) sort);
                    add_root_items(ref items, root, 1);
                    items.insert_sorted(new StorageItem.available(root.free, ((float) root.free / root.total) * 100, 1), (CompareFunc) sort);
                }
                else
                {
                    Storage? root = get_storage("/");
                    items.insert_sorted(new StorageItem.storage(_("Capacity"), root.mount_path, root.total, 0), (CompareFunc) sort);
                    add_root_items(ref items, root, 0);
                    add_home_items(ref items, root, 0);
                    items.insert_sorted(new StorageItem.available(root.free, ((float) root.free / root.total) * 100), (CompareFunc) sort);
                }

                set_colors(ref items, color);
                return items;
            } else
            {
                path_null = false;
                return get_items_for_path(path, color, parent, exclude_from_home);
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
                    case StorageItemPosition.THIRD:
                        if(b.get_prefered_position() != StorageItemPosition.FIRST &&
                            b.get_prefered_position() != StorageItemPosition.SECOND)
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
                            case StorageItemPosition.THIRD:
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
            uint showed_items_length = 1;
            foreach(StorageItem item in items)
            {
                if(item.get_percentage() > StorageGraph.MIN_PERCENTAGE_SHOWN_FILES)
                    showed_items_length++;
            }

            for(uint i = 0; i < items.length(); i++)
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
                        //6 because DOCUMENTS, DOWNLOADS, DESKTOP, MUSIC, PICTURES, VIDEOS, 2 because header and Home
                        item.set_color(generate_color(default_color, i-2, 6, false));
                        break;
                    case StorageItemType.DIRECTORY:
                    case StorageItemType.FILE:
                        item.set_color(generate_color(default_color, i, showed_items_length, true));
                        break;
                }
            }
        }

        private Gdk.RGBA generate_color(Gdk.RGBA default_color, uint order, uint all_color, bool reverse = false)
        {
            if(order >= all_color)
                order = all_color - 1;

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
            bool scan = false;
            if(force_override == true || cache == false)
               scan = true;

            if(scan && can_scan)
            {
                cache = false;
                can_scan = false;

                analyze_storages();
                stop_scanning();
                cancellable.reset();
                directory_size_table.remove_all();
                SourceFunc callback = create_cache.callback;

                ThreadFunc<void*> run = () => {
                    scan_cache();
                    Idle.add((owned) callback);
                    return null;
                };

                var thread = new Thread<void*>("storage_analyzer", run);
                yield;
                thread.join();

                cache = true;
                can_scan = true;
                cache_complete();
            }
        }

        public async void move_file(File src_file, File dest_file)
        {
            var src_parent = src_file.get_parent();
            var dest_parent = dest_file.get_parent();
            var type = src_file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            Array<string> folders_for_delete_from_cache = new Array<string>();
            uint64 size = 0;

            try {
                if(type == FileType.DIRECTORY)
                {
                    size = get_size_of_directory(src_file.get_parse_name());
                    get_folders_in_dir(src_file, ref folders_for_delete_from_cache);
                }
                else if(type == FileType.REGULAR)
                {
                    var file_info = src_file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    size = file_info.get_size();
                }

            	src_file.move (dest_file, FileCopyFlags.NONE, null);

            	recalculate_size_of_parents(src_parent, size, Operation.MINUS);
                recalculate_size_of_parents(dest_parent, size, Operation.PLUS);

                if(type == FileType.DIRECTORY)
                {
                    for(int i = 0; i < folders_for_delete_from_cache.length; i++)
                         directory_size_table.remove (folders_for_delete_from_cache.index(i));
                    add_to_cache(dest_file);
                }
            } catch (Error e) {
            	stderr.printf (e.message);
            }
        }

        public async void wipe_folder(string path)
        {
            var file = File.new_for_path(path);
            uint64 size = get_size_of_directory(path);
            var type = file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            try {
                if(type == FileType.DIRECTORY)
                {
                    FileEnumerator enumerator;
                    enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
                    FileInfo info;

                    while((info = enumerator.next_file(null)) != null)
                    {
                        directory_size_table.remove (file.get_child(info.get_name()).get_parse_name());
                        file.get_child(info.get_name()).trash();
                        add_to_cache(File.new_for_uri(TRASH_PATH));
                    }
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            recalculate_size_of_parents(file, size, Operation.MINUS);
        }

        public async void wipe_trash()
        {
            var file = File.new_for_uri(TRASH_PATH);

            try {
                FileEnumerator enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null)
                    file.get_child(info.get_name()).delete();
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            add_to_cache(file);
        }

        public async void trash_file(string path)
        {
            var file = File.new_for_path(path);
            var type = file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            Array<string> folders_for_delete_from_cache = new Array<string>();
            uint64 size = 0;

            try {
                if(type == FileType.DIRECTORY)
                {
                    size = get_size_of_directory(path);
                    get_folders_in_dir(file, ref folders_for_delete_from_cache);
                }
                else if(type == FileType.REGULAR)
                {
                    var file_info = file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    size = file_info.get_size();
                }
                file.trash();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            recalculate_size_of_parents(file.get_parent(), size, Operation.MINUS);

            if(type == FileType.DIRECTORY)
            {
                for(int i = 0; i < folders_for_delete_from_cache.length; i++)
                     directory_size_table.remove (folders_for_delete_from_cache.index(i));
            }

            add_to_cache(File.new_for_uri(TRASH_PATH));
        }

        public async void delete_trash_file(string path)
        {
            var file = File.new_for_uri(path);
            try {
                file.delete();
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
            add_to_cache(File.new_for_uri(TRASH_PATH));
        }

        public async void restore_trash_file(string path)
        {
            var file = File.new_for_uri(path);
            try {
                var file_info = file.query_info (file_attributes + "," + FileAttribute.TRASH_ORIG_PATH, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                move_file.begin(file, File.new_for_path(file_info.get_attribute_byte_string(FileAttribute.TRASH_ORIG_PATH)));
            } catch(Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        public async void delete_file(string path)
        {
            var file = File.new_for_path(path);
            var parent = file.get_parent();
            var type = file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            uint64 size = 0;

            if(type == FileType.DIRECTORY)
                size = get_size_of_directory(path);
            else if(type == FileType.REGULAR)
            {
                try {
                    var file_info = file.query_info (FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    size = file_info.get_size();
                } catch (Error e) {
                    stderr.printf ("Error: %s\n", e.message);
                }
            }

            delete_file_recursive(path, true);
            recalculate_size_of_parents(parent, size, Operation.MINUS);
        }

        private void get_folders_in_dir(File file, ref Array<string> folders)
        {
            try {
                FileEnumerator enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        var child = file.get_child(info.get_name());
                        get_folders_in_dir(child, ref folders);
                    }
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            folders.append_val(file.get_parse_name());
        }

        private uint64 add_to_cache(File file)
        {
            string path = file.get_parse_name();
            uint64 size = 0;

            try {
                FileEnumerator enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        var child = file.get_child(info.get_name());
                        size += add_to_cache(child);
                    }
                    else if(info.get_file_type() == FileType.REGULAR)
                    {
                        size += info.get_size();
                    }
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            directory_size_table.insert (path, size);
            return size;
        }

        private void recalculate_size_of_parents(File? parent, uint64 size, Operation operation)
        {
            uint64 orig_size = get_size_of_directory(parent.get_parse_name());
            uint64 new_size = 0;

            switch(operation)
            {
                case Operation.PLUS:
                    new_size = orig_size + size;
                    break;
                case Operation.MINUS:
                    new_size = orig_size - size;
                    break;
            }
            directory_size_table.replace(parent.get_parse_name(), new_size);

            foreach(string exclude in exclude_from_home)
            {
                if(parent.equal(File.new_for_path(exclude)))
                    return;
            }

            if(parent.equal(File.new_for_path(Environment.get_home_dir())))
                return;

            if(parent.get_parent() == null)
                return;

            recalculate_size_of_parents(parent.get_parent(), size, operation);
        }

        private void delete_file_recursive(string path, bool delete_basefile, bool uri = false)
        {
            File file;
            if(uri)
                file = File.new_for_uri(path);
            else
                file = File.new_for_path(path);

            var type = file.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

            try {
                if(type == FileType.DIRECTORY)
                {
                    FileEnumerator enumerator;
                    enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
                    FileInfo info;

                    while((info = enumerator.next_file(null)) != null)
                    {
                        string child = file.get_child(info.get_name()).get_parse_name();
                        delete_file_recursive(child, true, uri);
                    }
                }

                if(delete_basefile)
                {
                    file.delete();
                    directory_size_table.remove(path);
                }
                else
                    directory_size_table.replace(path, 0);
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        private void scan_cache()
        {
            var results_queue = new AsyncQueue<StorageResult>();
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

            var desktop   = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DESKTOP)), ref cancellable, ref results_queue);
            var documents = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DOCUMENTS)), ref cancellable, ref results_queue);
            var downloads = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.DOWNLOAD)), ref cancellable, ref results_queue);
            var music     = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.MUSIC)), ref cancellable, ref results_queue);
            var pictures  = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.PICTURES)), ref cancellable, ref results_queue);
            var videos    = new StorageWorker(File.new_for_path(Environment.get_user_special_dir(UserDirectory.VIDEOS)), ref cancellable, ref results_queue);
            var trash     = new StorageWorker(File.new_for_uri(TRASH_PATH), ref cancellable, ref results_queue);
            var home      = new StorageWorker(File.new_for_path(Environment.get_home_dir()), ref cancellable, ref results_queue, exclude_from_home);

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
                directory_size_table.insert (result.path, result.size);
            }
        }

        private void add_root_items(ref List<StorageItem> items, Storage storage, int section)
        {
        	uint64 root_size = storage.used;
        	if(separate_home == false)
        	{
        		uint64 home_size = get_size_of_directory(Environment.get_home_dir())
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DESKTOP))
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DOCUMENTS))
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DOWNLOAD))
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.MUSIC))
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.PICTURES))
							 + get_size_of_directory(Environment.get_user_special_dir(UserDirectory.VIDEOS))
							 + get_size_of_directory(TRASH_PATH);
				root_size -= home_size;
			}

            items.insert_sorted(new StorageItem.system(root_size, ((float) root_size / storage.total) * 100, section), (CompareFunc) sort);
        }

        private void add_home_items(ref List<StorageItem> items, Storage storage, int section)
        {
            uint64? user_size = get_size_of_directory(Environment.get_home_dir());
            if(user_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.USER,
                    StorageItemType.USER,
                    _("Home"),
                    Environment.get_home_dir(),
                    user_size,
                    ((float) user_size / storage.total) * 100,
                    section,
                    StorageItemPosition.THIRD), (CompareFunc) sort);
            }
            uint64? desktop_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DESKTOP));
            if(desktop_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DESKTOP,
                    StorageItemType.DESKTOP,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DESKTOP)),
                    Environment.get_user_special_dir(UserDirectory.DESKTOP),
                    desktop_size,
                    ((float) desktop_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? documents_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DOCUMENTS));
            if(documents_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DOCUMENTS,
                    StorageItemType.DOCUMENTS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DOCUMENTS)),
                    Environment.get_user_special_dir(UserDirectory.DOCUMENTS),
                    documents_size,
                    ((float) documents_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? downloads_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.DOWNLOAD));
            if(downloads_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.DOWNLOADS,
                    StorageItemType.DOWNLOADS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.DOWNLOAD)),
                    Environment.get_user_special_dir(UserDirectory.DOWNLOAD),
                    downloads_size,
                    ((float) downloads_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? music_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.MUSIC));
            if(music_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.MUSIC,
                    StorageItemType.MUSIC,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.MUSIC)),
                    Environment.get_user_special_dir(UserDirectory.MUSIC),
                    music_size,
                    ((float) music_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? pictures_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.PICTURES));
            if(pictures_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.PICTURES,
                    StorageItemType.PICTURES,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.PICTURES)),
                    Environment.get_user_special_dir(UserDirectory.PICTURES),
                    pictures_size,
                    ((float) pictures_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? videos_size = get_size_of_directory(Environment.get_user_special_dir(UserDirectory.VIDEOS));
            if(videos_size != null)
            {
                items.insert_sorted(new StorageItem.item(StorageItemType.VIDEOS,
                    StorageItemType.VIDEOS,
                    Path.get_basename(Environment.get_user_special_dir(UserDirectory.VIDEOS)),
                    Environment.get_user_special_dir(UserDirectory.VIDEOS),
                    videos_size,
                    ((float) videos_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
            uint64? trash_size = get_size_of_directory(TRASH_PATH);
            if(trash_size != null)
            {
                items.insert_sorted(new StorageItem.trash(
                    TRASH_PATH,
                    trash_size,
                    ((float) trash_size / storage.total) * 100,
                    section), (CompareFunc) sort);
            }
        }

        private List<StorageItem> get_items_for_path(string path, Gdk.RGBA color, StorageItemType parent, string[]? exclude_paths = null)
        {
            List<StorageItem> items = new List<StorageItem>();

            File file;
            FileEnumerator enumerator;

            if(parent == StorageItemType.TRASH)
            {
                parent = StorageItemType.TRASHFILE;
                file = File.new_for_uri(path);
            }
            else if(parent == StorageItemType.TRASHFILE || parent == StorageItemType.TRASHSUBFILE)
            {
                parent = StorageItemType.TRASHSUBFILE;
                file = File.new_for_uri(path);
            }
            else
                file = File.new_for_path(path);

            try {
                enumerator = file.enumerate_children(file_attributes, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null && cancellable.is_cancelled() == false)
                {
                    uint64 parent_size = get_size_of_directory(path);

                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        if(exclude_paths == null || !(file.resolve_relative_path(info.get_name()).get_path() in exclude_paths))
                        {
                            string folder_path = file.get_child(info.get_name()).get_parse_name();
                            uint64? folder_size = get_size_of_directory(folder_path);

                            if(folder_size != null)
                            {
                                double folder_percentage = ((float) folder_size / parent_size) * 100;

                                items.insert_sorted(new StorageItem.directory(parent, info.get_name(), folder_path, folder_size,
                                    folder_percentage), (CompareFunc) sort);
                            }
                        }
                    }
                    else if(info.get_file_type() == FileType.REGULAR)
                    {
                        float percentage = ((float) info.get_size() / parent_size) * 100;

                        items.insert_sorted(new StorageItem.file(parent, info.get_name(),
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
            directory_size_table = new HashTable<string, uint64?>(str_hash, str_equal);
            storages = new HashTable<string, Storage?>(str_hash, str_equal);
            exclude_from_home = {
                Environment.get_user_special_dir(UserDirectory.DESKTOP),
                Environment.get_user_special_dir(UserDirectory.DOCUMENTS),
                Environment.get_user_special_dir(UserDirectory.DOWNLOAD),
                Environment.get_user_special_dir(UserDirectory.MUSIC),
                Environment.get_user_special_dir(UserDirectory.PICTURES),
                Environment.get_user_special_dir(UserDirectory.VIDEOS),
                Environment.get_user_data_dir() + "/Trash/files"
            };
        }
    }
}
