/* egg-state-machine-buildable.h
 *
 * Copyright (C) 2015 Christian Hergert <christian@hergert.me>
 *
 * This file is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 3 of the
 * License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef EGG_STATE_MACHINE_BUILDABLE_H
#define EGG_STATE_MACHINE_BUILDABLE_H

#include <gtk/gtk.h>

G_BEGIN_DECLS

void egg_state_machine_buildable_iface_init (GtkBuildableIface *iface);

G_END_DECLS

#endif /* EGG_STATE_MACHINE_BUILDABLE_H */
