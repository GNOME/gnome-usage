/* quit-process-dialog.vala
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
 * Authors: Felipe Borges <felipeborges@gnome.org>
 */

using Gtk;

namespace Usage
{
    public enum TerminateSignals
    {
        SIGKILL,
        SIGTERM
    }

    [GtkTemplate (ui = "/org/gnome/Usage/ui/quit-process-dialog.ui")]
    public class QuitProcessDialog : Gtk.MessageDialog
    {
        private Process process;

        public QuitProcessDialog(Process process)
        {
            this.process = process;

            this.text = this.text.printf(process.display_name);
        }

        [GtkCallback]
        private void on_force_quit_button_clicked ()
        {
            if(this.process.sub_processes != null)
            {
                var sub_processes_pids = this.process.sub_processes.get_keys();
                foreach(Pid pid in sub_processes_pids)
                    kill(pid);
            }

            kill(this.process.pid);

            this.destroy();
        }

        private void kill (Pid pid)
        {
            var settings = Settings.get_default();
            int terminate_signal;

            switch(settings.get_enum("terminate-signal-processes")) {
                case TerminateSignals.SIGKILL:
                    terminate_signal = Posix.Signal.KILL;
                    break;
                case TerminateSignals.SIGTERM:
                default:
                    terminate_signal = Posix.Signal.TERM;
                    break;
            }

            debug ("Terminating %d", (int) pid);
            Posix.kill(pid, terminate_signal);
        }

        [GtkCallback]
        public void cancel ()
        {
            /* FIXME: For some reason we are not able to connect to the
             * destroy signal right from the .ui file. */
            this.destroy();
        }
    }
}
