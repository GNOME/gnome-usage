vala_sources = [
  'animated-scrolled-window.vala',
  'app-item.vala',
  'application.vala',
  'color-rectangle.vala',
  'cpu-graph-model.vala',
  'cpu-graph.vala',
  'cpu-monitor.vala',
  'cpu-sub-view.vala',
  'gnome-usage.vala',
  'graph-box.vala',
  'graph-stacked-renderer.vala',
  'graph-stack-switcher.vala',
  'graph-switcher-button.vala',
  'header-bar.vala',
  'memory-graph-model.vala',
  'memory-graph.vala',
  'memory-monitor.vala',
  'memory-speedometer.vala',
  'memory-sub-view.vala',
  'monitor.vala',
  'no-results-found-view.vala',
  'performance-view.vala',
  'pie-chart.vala',
  'primary-menu.vala',
  'process-list-box.vala',
  'process-row.vala',
  'process.vala',
  'quit-process-dialog.vala',
  'settings.vala',
  'speedometer.vala',
  'storage/query-builder.vala',
  'storage/storage-view-item.vala',
  'storage/storage-view.vala',
  'storage/storage-view-row.vala',
  'storage/tracker-controller.vala',
  'storage/tracker-worker.vala',
  'storage-graph.vala',
  'swap-speedometer.vala',
  'system-monitor.vala',
  'utils.vala',
  'view.vala',
  'window.vala'
]

deps = [
  gio_dep,
  glib_dep,
  gobject_dep,
  gtk_dep,
  libgtop_dep,
  tracker_dep,
  libdazzle_dep,
  cc.find_library('m'),
  valac.find_library('config', dirs: vapi_dir),
  valac.find_library('posix')
]

c_args = [
  '-DVERSION="@0@"'.format(meson.project_version()),
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-DGNOMELOCALEDIR="@0@"'.format(join_paths(get_option('prefix'), get_option('localedir')))
]

executable(
  meson.project_name(),
  vala_sources + resources,
  dependencies: deps,
  c_args: c_args,
  vala_args: '--vapidir=' + vapi_dir,
  install: true
)
