namespace Usage
{
    [Compact]
    public class StorageResult {
        internal string path;
        internal uint64 size;
        internal float percentage;
    }

    public class StorageWorker
    {
        private AsyncQueue<StorageResult> results_queue;
        private File path;
        private string[] exclude_paths;
        private Cancellable cancellable;
        private string? name;
        private uint64 total_size;

        public StorageWorker(File path, uint64 total_size, ref Cancellable cancellable, ref AsyncQueue<StorageResult> results_queue, string? name = null, string[]? exclude_paths = null)
        {
            this.path = path;
            this.cancellable = cancellable;
            this.name = name;
            this.exclude_paths = exclude_paths;
            this.results_queue = results_queue;
            this.total_size = total_size;
        }

        private StorageResult get_directory(File file, out uint64 size)
        {
            string path = file.get_parse_name();
            FileEnumerator enumerator;
            List<StorageResult> childs = new List<StorageResult>();
            size = 0;

            try {
                enumerator = file.enumerate_children(FileAttribute.STANDARD_SIZE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null && cancellable.is_cancelled() == false)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        if(exclude_paths == null || !(file.resolve_relative_path(info.get_name()).get_path() in exclude_paths))
                        {
                            var child = file.get_child(info.get_name());
                            uint64 child_size = 0;
                            childs.append(get_directory(child, out child_size));
                            size += child_size;
                        }
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

            StorageResult result = new StorageResult();
            result.path = path;
            result.size = size;

            foreach (unowned StorageResult child in childs)
            {
                child.percentage = ((float) child.size / size) * 100;
                var child_copy = new StorageResult();
                child_copy.path = child.path;
                child_copy.size = child.size;
                child_copy.percentage = child.percentage;
                results_queue.push ((owned) child_copy);
            }

            return result;
        }

        public void run ()
        {
            uint64 size = 0;
            var child = get_directory(path, out size);
            child.percentage = ((float) size / total_size) * 100;
            results_queue.push ((owned) child);
        }
    }
}