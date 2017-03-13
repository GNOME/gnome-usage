sources = [
    'realtime-graphs.h',
    'rg-column.c',
    'rg-column.h',
    'rg-column-private.h',
    'rg-cpu-graph.c',
    'rg-cpu-graph.h',
    'rg-cpu-table.c',
    'rg-cpu-table.h',
    'rg-graph.c',
    'rg-graph.h',
    'rg-line-renderer.c',
    'rg-line-renderer.h',
    'rg-stacked-renderer.c',
    'rg-stacked-renderer.h',
    'rg-renderer.c',
    'rg-renderer.h',
    'rg-ring.c',
    'rg-ring.h',
    'rg-table.c',
    'rg-table.h']

rg_lib = static_library( 'rg', sources, dependencies : [glib, gobject, gio, gtk],
   include_directories : include_directories('../egg'), install : false)

rg = declare_dependency(link_with : rg_lib,
  include_directories : include_directories('.'))
