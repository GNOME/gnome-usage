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
 */

namespace Usage
{
    public class StorageView : View
    {
        private StorageListBox storage_list_box;
        private Gtk.Revealer revealer;
        private StorageActionBar action_bar;

        public StorageView ()
        {
            name = "STORAGE";
            title = _("Storage");

            storage_list_box = new StorageListBox();
            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            scrolled_window.add(storage_list_box);

            var spinner = new Gtk.Spinner();
            spinner.active = true;
            spinner.margin_top = 30;
            spinner.margin_bottom = 20;

            var graph = new StorageGraph();
            var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.position = 300;
            paned.add2(spinner);

            var center_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            var image = new Gtk.Image.from_icon_name("folder-symbolic", Gtk.IconSize.DIALOG );
            image.pixel_size = 128;
            center_box.add(image);

            Gtk.Label empty_label = new Gtk.Label("<span size='xx-large' font_weight='bold'>" + _("No content here") + "</span>");
            empty_label.set_use_markup (true);
            empty_label.margin_top = 10;
            center_box.add(empty_label);
            center_box.get_style_context().add_class("dim-label");
            var empty_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            empty_box.set_center_widget(center_box);
            empty_box.show_all();

            storage_list_box.loading.connect(() =>
            {
                paned.remove(empty_box);
                paned.remove(scrolled_window);
                paned.remove(graph);
                paned.add2(spinner);
            });

            storage_list_box.loaded.connect(() =>
            {
                paned.add1(scrolled_window);
                scrolled_window.show();

                paned.remove(spinner);
                paned.add2(graph);
                graph.show();
            });

            storage_list_box.empty.connect(() =>
            {
                paned.remove(scrolled_window);
                paned.remove(graph);
                paned.remove(spinner);
                paned.add2(empty_box);
                empty_label.show();
            });

            action_bar = new StorageActionBar();

            revealer = new Gtk.Revealer();
            revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            revealer.transition_duration = 400;
            revealer.add(action_bar);

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(paned, true);
            box.pack_end(revealer, false);
            add(box);
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
