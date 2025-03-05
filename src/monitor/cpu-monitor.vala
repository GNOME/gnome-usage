/* cpu-monitor.vala
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

public class Usage.CpuMonitor : Monitor {
    private double cpu_load;
    private double[] x_cpu_load;
    private uint64 cpu_last_used = 0;
    private uint64 cpu_last_total = 0;
    private uint64 cpu_last_total_step = 0;
    private uint64[] x_cpu_last_used;
    private uint64[] x_cpu_last_total;

    public CpuMonitor () {
        x_cpu_load = new double[get_num_processors ()];
        x_cpu_last_used = new uint64[get_num_processors ()];
        x_cpu_last_total = new uint64[get_num_processors ()];
    }

    public void update () {
        GTop.Cpu cpu_data;
        GTop.get_cpu (out cpu_data);
        var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
        cpu_load = ((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total);
        cpu_last_total_step = cpu_data.total - cpu_last_total;

        var x_cpu_used = new uint64[get_num_processors ()];
        for (int i = 0; i < x_cpu_load.length; i++) {
            x_cpu_used[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
            x_cpu_load[i] = ((double) (x_cpu_used[i] - x_cpu_last_used[i])) / (cpu_data.xcpu_total[i] - x_cpu_last_total[i]);
        }

        cpu_last_used = used;
        cpu_last_total = cpu_data.total;
        x_cpu_last_used = x_cpu_used;
        x_cpu_last_total = cpu_data.xcpu_total;
    }

    public double get_cpu_load () {
        return cpu_load;
    }

    public double[] get_x_cpu_load () {
        return x_cpu_load;
    }

    public void update_process (ref Process process) {
        GTop.ProcTime proc_time;
        GTop.ProcState proc_state;

        GTop.get_proc_time (out proc_time, process.pid);
        GTop.get_proc_state (out proc_state, process.pid);

        process.last_processor = proc_state.last_processor;
        double cpu_load = ((double) (proc_time.rtime - process.cpu_last_used)) / cpu_last_total_step;
        process.cpu_load = double.min (1, cpu_load);
        process.cpu_last_used = proc_time.rtime;
        process.x_cpu_last_used = proc_time.xcpu_utime[process.last_processor] + proc_time.xcpu_stime[process.last_processor];
        process.start_time = proc_time.start_time;
    }
}
