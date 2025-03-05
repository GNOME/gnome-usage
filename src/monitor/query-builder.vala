/* query-builder.vala
 *
 * Copyright (C) 2018 Red Hat, Inc.
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

public class Usage.StorageQueryBuilder {
    public string enumerate_children (string uri, bool recursive = false) {
        string filter;
        if (recursive) {
            filter = @"tracker:uri-is-descendant ('$uri', ?uri)";  
        } else {
            filter = @"tracker:uri-is-parent ('$uri', ?uri)";
        }

        return @"SELECT ?uri rdf:type(?u) FROM tracker:FileSystem { ?u nie:url ?uri . FILTER($filter) }";
    }
}
