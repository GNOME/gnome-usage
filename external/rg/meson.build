sources = [
    'rg-column.c',
    'rg-cpu-graph.c',
    'rg-cpu-table.c',
    'rg-graph.c',
    'rg-line-renderer.c',
    'rg-stacked-renderer.c',
    'rg-renderer.c',
    'rg-ring.c',
    'rg-table.c']

rg_lib = static_library( 'rg', sources, dependencies : [glib, gobject, gio, gtk],
   include_directories : include_directories('../egg'), install : false)

rg = declare_dependency(link_with : rg_lib,
  include_directories : include_directories('.'))
