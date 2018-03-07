vala_sources = [
  'application.vala',
  'color-rectangle.vala',
  'cpu-graph-table.vala',
  'cpu-graph.vala',
  'cpu-monitor.vala',
  'cpu-sub-view.vala',
  'gnome-usage.vala',
  'graph-block-row.vala',
  'graph-block.vala',
  'graph-box.vala',
  'graph-stack-switcher.vala',
  'graph-switcher-button.vala',
  'header-bar.vala',
  'memory-graph-table.vala',
  'memory-graph.vala',
  'memory-monitor.vala',
  'memory-speedometer.vala',
  'memory-sub-view.vala',
  'monitor.vala',
  'no-results-found-view.vala',
  'performance-view.vala',
  'pie-chart.vala',
  'process-list-box.vala',
  'process-row.vala',
  'process.vala',
  'quit-process-dialog.vala',
  'settings.vala',
  'speedometer.vala',
  'storage-actionbar.vala',
  'storage-analyzer.vala',
  'storage-graph.vala',
  'storage-item.vala',
  'storage-list-box.vala',
  'storage-row.vala',
  'storage-view.vala',
  'storage-worker.vala',
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
  libegg_dep,
  librg_dep,
  dependency('libgtop-2.0', version : '>= 2.34.0'),
  cc.find_library('m'),
  valac.find_library('config', dirs: vapi_dir),
  valac.find_library('egg', dirs: vapi_dir),
  valac.find_library('posix'),
  valac.find_library('rg', dirs: vapi_dir)
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
