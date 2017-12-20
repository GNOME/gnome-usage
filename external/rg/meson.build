sources = [
  'rg-column.c',
  'rg-cpu-graph.c',
  'rg-cpu-table.c',
  'rg-graph.c',
  'rg-line-renderer.c',
  'rg-stacked-renderer.c',
  'rg-renderer.c',
  'rg-ring.c',
  'rg-table.c'
]

deps = [
  gio_dep,
  glib_dep,
  gobject_dep,
  gtk_dep
]

librg = static_library(
  'rg',
  sources: sources,
  dependencies: deps,
  include_directories: egg_inc
)

librg_dep = declare_dependency(
  link_with: librg,
  include_directories: include_directories('.')
)
