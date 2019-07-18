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
        public uint uid { get; private set; }

        public double cpu_load { get; set; default = 0; }
        public double x_cpu_load { get; set; default = 0; }
        public uint64 cpu_last_used { get; set; default = 0; }
        public uint64 x_cpu_last_used { get; set; default = 0; }
        public uint last_processor { get; set; default = 0; }

        public uint64 mem_usage { get; set; default = 0; }

        public bool gamemode { get; set; }

        public bool mark_as_updated { get; set; default = true; }
        public ProcessStatus status { get; private set; default = ProcessStatus.SLEEPING; }

        public Process(Pid pid, string cmdline)
        {
            this.pid = pid;
            this.cmdline = cmdline;
            this.uid = _get_uid();
        }

        public void update_status ()
        {
            GTop.ProcState proc_state;
            GTop.get_proc_state (out proc_state, pid);

            switch(proc_state.state)
            {
                case GTop.PROCESS_RUNNING:
                case GTop.PROCESS_UNINTERRUPTIBLE:
                    status = ProcessStatus.RUNNING;
                    break;
                case GTop.PROCESS_SWAPPING:
                case GTop.PROCESS_INTERRUPTIBLE:
                case GTop.PROCESS_STOPPED:
                    status = ProcessStatus.SLEEPING;
                    break;
                case GTop.PROCESS_DEAD:
                case GTop.PROCESS_ZOMBIE:
                default:
                    status = ProcessStatus.DEAD;
                    break;
            }

            if(cpu_load > 0)
                status = ProcessStatus.RUNNING;

            mark_as_updated = true;
        }

        private uint _get_uid()
        {
            GTop.ProcUid procUid;
            GTop.get_proc_uid(out procUid, pid);
            return procUid.uid;
        }

        /* static utility methods */
        public static string? sanitize_name (string name) {
            string? result = null;

            if (name == null)
                return null;

            try {
                var rgx = new Regex ("[^a-zA-Z0-9._-]");
                result = rgx.replace (name, name.length, 0, "");
            } catch (RegexError e) {
                warning ("Unable to sanitize name: %s", e.message);
            }

            return result;
        }

        public static string first_component (string str) {

            for (int i = 0; i < str.length; i++) {
                if (str[i] == ' ') {
                    return str.substring(0, i);
                }
            }

            return str;
        }
    }

    public enum ProcessStatus
    {
        RUNNING,
        SLEEPING,
        DEAD
    }
}
