/* memory-monitor.vala
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

public class Usage.MemoryMonitor : Monitor {
    private uint64 ram_usage;
    private uint64 ram_total;
    private uint64 swap_usage;
    private uint64 swap_total;

    public void update () {
        /* Memory */
        GTop.Mem mem;
        GTop.get_mem (out mem);
        ram_usage = mem.user;
        ram_total = mem.total;

        /* Swap */
        GTop.Swap swap;
        GTop.get_swap (out swap);
        swap_usage = swap.used;
        swap_total = swap.total;
    }

    public uint64 get_ram_usage () {
        return ram_usage;
    }
    public uint64 get_swap_usage () {
        return swap_usage;
    }
    public uint64 get_ram_total () {
        return ram_total;
    }
    public uint64 get_swap_total () {
        return swap_total;
    }

    public void update_process (ref Process process) {
        GTop.Mem mem;
        GTop.ProcMem proc_mem;

        GTop.get_mem (out mem);
        GTop.get_proc_mem (out proc_mem, process.pid);

        process.mem_usage = proc_mem.resident - proc_mem.share;
    }
}
