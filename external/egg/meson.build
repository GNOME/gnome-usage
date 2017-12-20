egg_inc = include_directories('.')

sources = [
  'egg-animation.c',
  'egg-binding-group.c',
  'egg-box.c',
  'egg-centering-bin.c',
  'egg-column-layout.c',
  'egg-counter.c',
  'egg-date-time.c',
  'egg-empty-state.c',
  'egg-entry-box.c',
  'egg-file-chooser-entry.c',
  'egg-frame-source.c',
  'egg-heap.c',
  'egg-list-box.c',
  'egg-menu-manager.c',
  'egg-pill-box.c',
  'egg-priority-box.c',
  'egg-radio-box.c',
  'egg-scrolled-window.c',
  'egg-search-bar.c',
  'egg-settings-flag-action.c',
  'egg-settings-sandwich.c',
  'egg-signal-group.c',
  'egg-simple-label.c',
  'egg-simple-popover.c',
  'egg-slider.c',
  'egg-state-machine-buildable.c',
  'egg-state-machine.c',
  'egg-task-cache.c',
  'egg-three-grid.c',
  'egg-widget-action-group.c'
]

deps = [
  gio_dep,
  glib_dep,
  gobject_dep,
  gtk_dep
]

libegg = static_library(
  'egg',
  sources: sources,
  dependencies: deps
)

libegg_dep = declare_dependency(
  link_with: libegg,
  include_directories: egg_inc
)
