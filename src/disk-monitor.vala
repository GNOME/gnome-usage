/* disk-monitor.vala
 *
 * Copyright (C) 2019 Red Hat, Inc.
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

namespace Usage {
    public class DiskMonitor : Monitor {
        public uint64 read_bytes { get; private set; }
        public uint64 write_bytes { get; private set; }

        public void update() {
            read_bytes = 0;
            write_bytes = 0;
        }

        public void update_process(ref Process process, bool first_update) {
            GTop.ProcIo proc_io;
            GTop.get_proc_io (out proc_io, process.pid);

            if(!first_update)
                process.disk_read = proc_io.disk_rbytes - process.disk_read_last;
            process.disk_read_last = proc_io.disk_rbytes;
            read_bytes += process.disk_read;

            if(!first_update)
                process.disk_write = proc_io.disk_wbytes - process.disk_write_last;
            process.disk_write_last = proc_io.disk_wbytes;
            write_bytes += process.disk_write;
        }
    }
}
