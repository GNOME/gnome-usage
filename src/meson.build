vala_sources = [
  'animated-scrolled-window.vala',
  'app-item.vala',
  'application.vala',
  'cpu-graph.vala',
  'cpu-monitor.vala',
  'cpu-sub-view.vala',
  'gnome-usage.vala',
  'game-mode.vala',
  'graph.vala',
  'graph-box.vala',
  'graph-stack-switcher.vala',
  'graph-switcher-button.vala',
  'memory-graph.vala',
  'memory-monitor.vala',
  'memory-speedometer.vala',
  'memory-sub-view.vala',
  'monitor.vala',
  'no-results-found-view.vala',
  'performance-graph-view.vala',
  'performance-view.vala',
  'process-list-box.vala',
  'process-row-item.vala',
  'process-user-tag.vala',
  'process.vala',
  'quit-process-dialog.vala',
  'settings.vala',
  'speedometer.vala',
  'stack-list.vala',
  'storage/storage-actionbar.vala',
  'storage/storage-graph.vala',
  'storage/query-builder.vala',
  'storage/storage-row-popover.vala',
  'storage/storage-view-item.vala',
  'storage/storage-view.vala',
  'storage/storage-view-row.vala',
  'storage/tracker-controller.vala',
  'storage/tracker-worker.vala',
  'swap-speedometer.vala',
  'system-monitor.vala',
  'utils.vala',
  'view.vala',
  'window.vala'
]

deps = [
  gee_dep,
  gio_dep,
  gio_unix_dep,
  glib_dep,
  gobject_dep,
  gtk_dep,
  libgtop_dep,
  tracker_dep,
  libadwaita_dep,
  cc.find_library('m'),
  valac.find_library('config', dirs: vapi_dir),
  valac.find_library('stopgap', dirs: vapi_dir),
  valac.find_library('posix')
]

c_args = [
  '-DVERSION="@0@@1@"'.format(meson.project_version(), version_suffix),
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-DGNOMELOCALEDIR="@0@"'.format(join_paths(get_option('prefix'), get_option('localedir'))),
  '-DPROFILE="@0@"'.format(profile),
  '-DAPPLICATION_ID="@0@"'.format(application_id),
  '-DAPPLICATION_RESOURCE_PATH="@0@"'.format(resource_path)
]

executable(
  meson.project_name(),
  vala_sources + resources,
  dependencies: deps,
  c_args: c_args,
  vala_args: vapi_dirs,
  install: true
)
