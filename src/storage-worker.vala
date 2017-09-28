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
    public enum StorageMessageType {
        RESULT,
        SIZE_UPDATE,
        FINISH,
    }

    [Compact]
    public class StorageMessage {
        public StorageMessageType type;
        public uint64 size;
        public string? path;
    }

    public class StorageWorker
    {
        private AsyncQueue<StorageMessage> msg_queue;
        private File path;
        private string[] exclude_paths;
        private Cancellable cancellable;

        public StorageWorker(File path, ref Cancellable cancellable, ref AsyncQueue<StorageMessage> msg_queue, string[]? exclude_paths = null)
        {
            this.path = path;
            this.cancellable = cancellable;
            this.exclude_paths = exclude_paths;
            this.msg_queue = msg_queue;
        }

        private uint64 get_directory(File file)
        {
            string path = file.get_parse_name();
            uint64 size = 0;

            try {
                FileEnumerator enumerator = file.enumerate_children(FileAttribute.STANDARD_SIZE + "," + FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
                FileInfo info;
                Queue<File> to_recurse = new Queue<File>();

                while((info = enumerator.next_file(null)) != null && cancellable.is_cancelled() == false)
                {
                    if(info.get_file_type() == FileType.DIRECTORY)
                    {
                        if(exclude_paths == null || !(file.resolve_relative_path(info.get_name()).get_path() in exclude_paths))
                        {
                            var child = file.get_child(info.get_name());
                            to_recurse.push_tail(child);
                        }
                    }
                    else if(info.get_file_type() == FileType.REGULAR)
                    {
                        size += info.get_size();
                    }
                }

                if(size > 0)
                {
                    StorageMessage msg = new StorageMessage();
                    msg.type = StorageMessageType.SIZE_UPDATE;
                    msg.path = path;
                    msg.size = size;
                    msg_queue.push((owned) msg);
                }

                File child = null;
                while ((child = to_recurse.pop_head()) != null) {
                    size += get_directory(child);
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            StorageMessage result = new StorageMessage();
            result.type = StorageMessageType.RESULT;
            result.path = path;
            result.size = size;
            msg_queue.push ((owned) result);

            return size;
        }

        public void run ()
        {
            get_directory(path);

            // signal that we are finished
            StorageMessage msg = new StorageMessage();
            msg.type = StorageMessageType.FINISH;
            msg_queue.push ((owned) msg);

        }
    }
}
