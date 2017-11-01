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
    [GtkTemplate (ui = "/org/gnome/Usage/ui/quit-process-dialog.ui")]
	public class QuitProcessDialog : Gtk.MessageDialog
	{
        Pid pid { set; get; }

        public QuitProcessDialog(Pid pid, string app_name)
        {
            this.text = this.text.printf(app_name);
        }

        [GtkCallback]
        private void on_force_quit_button_clicked ()
        {
            debug ("Terminating %d", (int) this.pid);
            Posix.kill(this.pid, Posix.SIGKILL);

            this.destroy();
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
