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
        Pid pid;
        string cmdline;
        string cmdline_parameter; //Isn't parameters as "-p" etc, but parameter for running app, for ex. "--writer' with libreoffice, or "privacy" with gnome-control-center
        string display_name;
        double cpu_load;
        double x_cpu_load;
        uint64 cpu_last_used;
        uint64 x_cpu_last_used;
        uint last_processor;
        uint64 mem_usage;
        HashTable<Pid?, Process>? sub_processes;
        bool alive;
        ProcessStatus status;

        public Process(Pid pid, string cmdline, string cmdline_parameter, string display_name)
        {
            this.pid = pid;
            this.cmdline = cmdline;
            this.cmdline_parameter = cmdline_parameter;
            this.display_name = display_name;
            this.cpu_load = 0;
            this.x_cpu_load = 0;
            this.cpu_last_used = 0;
            this.x_cpu_last_used = 0;
            this.last_processor = 0;
            this.mem_usage = 0;
            this.sub_processes = null;
            this.alive = true;
            this.status = ProcessStatus.SLEEPING;
        }

        public void update_from_process(Process process)
        {
            this.last_processor = process.get_last_processor();
            this.cpu_load = process.get_cpu_load();
            this.x_cpu_load = process.get_x_cpu_load();
            this.cpu_last_used = process.get_cpu_last_used();
            this.x_cpu_last_used = process.get_x_cpu_last_used();
            this.mem_usage = process.get_mem_usage();
            this.alive = process.get_alive();
            this.status = process.get_status();
        }

        public Pid get_pid()
        {
            return pid;
        }

        public void set_pid(Pid pid)
        {
            this.pid = pid;
        }

        public string get_cmdline()
        {
            return cmdline;
        }

        public void set_cmdline(string cmdline)
        {
            this.cmdline = cmdline;
        }

        public string get_cmdline_parameter()
        {
            return cmdline_parameter;
        }

        public void set_cmdline_parameter(string cmdline_parameter)
        {
            this.cmdline_parameter = cmdline_parameter;
        }

        public string get_display_name()
        {
            return display_name;
        }

        public void set_display_name(string display_name)
        {
            this.display_name = display_name;
        }

        public double get_cpu_load()
        {
            return cpu_load;
        }

        public void set_cpu_load(double cpu_load)
        {
            this.cpu_load = cpu_load;
        }

        public double get_x_cpu_load()
        {
            return x_cpu_load;
        }

        public void set_x_cpu_load(double x_cpu_load)
        {
            this.x_cpu_load = x_cpu_load;
        }

        public uint64 get_cpu_last_used()
        {
            return cpu_last_used;
        }

        public void set_cpu_last_used(uint64 cpu_last_used)
        {
            this.cpu_last_used = cpu_last_used;
        }

        public uint64 get_x_cpu_last_used()
        {
            return x_cpu_last_used;
        }

        public void set_x_cpu_last_used(uint64 x_cpu_last_used)
        {
            this.x_cpu_last_used = x_cpu_last_used;
        }

        public uint get_last_processor()
        {
            return last_processor;
        }

        public void set_last_processor(uint last_processor)
        {
            this.last_processor = last_processor;
        }

        public uint64 get_mem_usage()
        {
            return mem_usage;
        }

        public void set_mem_usage(uint64 mem_usage)
        {
            this.mem_usage = mem_usage;
        }

        public HashTable<Pid?, Process>? get_sub_processes()
        {
            return sub_processes;
        }

        public void set_sub_processes(HashTable<Pid?, Process>? sub_processes)
        {
            this.sub_processes = sub_processes;
        }

        public bool get_alive()
        {
            return alive;
        }

        public void set_alive(bool alive)
        {
            this.alive = alive;
        }

        public ProcessStatus get_status()
        {
            return status;
        }

        public void set_status(ProcessStatus status)
        {
            this.status = status;
        }
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}
