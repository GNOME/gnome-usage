/* storage-view.vala
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
 *          Felipe Borges <felipeborges@gnome.org>
 */

namespace Usage
{
    [GtkTemplate (ui = "/org/gnome/Usage/ui/storage-view.ui")]
    public class StorageView : View
    {
        private StorageListBox storage_list_box;
        private StorageActionBar action_bar;

        [GtkChild]
        private Gtk.Revealer revealer;

        [GtkChild]
        private Gtk.Stack stack;

        [GtkChild]
        private Gtk.ScrolledWindow scrolled_window;

        [GtkChild]
        private Gtk.Paned paned;

        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            /* It would be nice being able to this in the template file. */
            storage_list_box = new StorageListBox();
            scrolled_window.add(storage_list_box);

            var graph = new StorageGraph();
            paned.add2(graph);
            graph.show();

            action_bar = new StorageActionBar();
            revealer.add(action_bar);

            storage_list_box.loading.connect(() =>
            {
                stack.set_visible_child_name("spinner");
            });

            storage_list_box.loaded.connect(() =>
            {
                stack.set_visible_child_name("content");
            });

            storage_list_box.empty.connect(() =>
            {
                stack.set_visible_child_name("empty");
            });
        }

        public StorageListBox get_storage_list_box()
        {
            return storage_list_box;
        }

        public StorageActionBar get_action_bar()
        {
            return action_bar;
        }

        public void show_action_bar(bool show)
        {
            revealer.set_reveal_child(show);
            action_bar.hide_all();
        }
    }
}
