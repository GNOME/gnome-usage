resource_data = files(
  'interface/adwaita.css',
  'ui/primary-menu.ui',
  'ui/header-bar.ui',
  'ui/memory-speedometer.ui',
  'ui/no-results-found-view.ui',
  'ui/performance-view.ui',
  'ui/process-row.ui',
  'ui/quit-process-dialog.ui',
  'ui/speedometer.ui',
  'ui/storage-actionbar.ui',
  'ui/storage-row-popover.ui',
  'ui/storage-view.ui',
  'ui/swap-speedometer.ui'
)

gresource = 'org.gnome.Usage'

resources = gnome.compile_resources(
  gresource,
  gresource + '.gresource.xml',
  c_name: 'resources',
  dependencies: resource_data
)

install_data('org.gnome.Usage.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')

desktop = 'org.gnome.Usage.desktop'

i18n.merge_file(
  desktop,
  type: 'desktop',
  input: desktop + '.in',
  output: desktop,
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

appdata = 'org.gnome.Usage.appdata.xml'

i18n.merge_file(
  appdata,
  input: appdata + '.in',
  output: appdata,
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_subdir(
  'icons/hicolor',
  install_dir: join_paths(get_option('datadir'), 'icons')
)
