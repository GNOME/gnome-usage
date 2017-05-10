/* storage-worker.vala
 *
 * Copyright (C) 2017 Red Hat, Inc.
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
 * Authors: Petr Štětka <pstetka@redhat.com>
 */

namespace Usage
{
    [Compact]
    public class StorageResult {
        public string path;
        public uint64 size;
    }

    public class StorageWorker
    {
        private AsyncQueue<StorageResult> results_queue;
        private File path;
        private string[] exclude_paths;
        private Cancellable cancellable;

        public StorageWorker(File path, ref Cancellable cancellable, ref AsyncQueue<StorageResult> results_queue, string[]? exclude_paths = null)
        {
            this.path = path;
            this.cancellable = cancellable;
            this.exclude_paths = exclude_paths;
            this.results_queue = results_queue;
        }

        private uint64 get_directory(File file)
        {
            string path = file.get_parse_name();
            uint64 size = 0;

            try {
                FileEnumerator enumerator = file.enumerate_children(FileAttribute.STANDARD_SIZE + "," + FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;

                while((info = enumerator.next_file(null)) != null && cancellable.is_cancelled() == false)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        if(exclude_paths == null || !(file.resolve_relative_path(info.get_name()).get_path() in exclude_paths))
                        {
                            var child = file.get_child(info.get_name());
                            size += get_directory(child);
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
            results_queue.push ((owned) result);

            return size;
        }

        public void run ()
        {
            get_directory(path);
        }
    }
}
