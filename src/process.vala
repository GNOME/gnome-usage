/* process.vala
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
    public class Process : Object
    {
        public Pid pid { get; private set; }
        public string cmdline { get; private set; }
        public string cmdline_parameter { get; private set; } //Isn't parameters as "-p" etc, but parameter for running app, for ex. "--writer' with libreoffice, or "privacy" with gnome-control-center
        public string display_name { get; private set; }
        public string user_name { get; private set; }

        public double cpu_load { get; set; default = 0; }
        public double x_cpu_load { get; set; default = 0; }
        public uint64 cpu_last_used { get; set; default = 0; }
        public uint64 x_cpu_last_used { get; set; default = 0; }
        public uint last_processor { get; set; default = 0; }

        public uint64 mem_usage { get; set; default = 0; }

        public HashTable<Pid?, Process>? sub_processes { get; set; }

        public bool alive { get; set; default = true; }
        public ProcessStatus status { get; set; default = ProcessStatus.SLEEPING; }

        public Process(Pid pid, string cmdline, string cmdline_parameter, string display_name, string user_name)
        {
            this.pid = pid;
            this.cmdline = cmdline;
            this.cmdline_parameter = cmdline_parameter;
            this.display_name = display_name;
            this.user_name = user_name;
        }

        public void update_from_process(Process process)
        {
            this.last_processor = process.last_processor;
            this.cpu_load = process.cpu_load;
            this.x_cpu_load = process.x_cpu_load;
            this.cpu_last_used = process.cpu_last_used;
            this.x_cpu_last_used = process.x_cpu_last_used;
            this.mem_usage = process.mem_usage;
            this.alive = process.alive;
            this.status = process.status;
        }
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}
