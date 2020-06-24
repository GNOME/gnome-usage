resource_data = files(
  'interface/adwaita.css',
  'ui/primary-menu.ui',
  'ui/memory-speedometer.ui',
  'ui/no-results-found-view.ui',
  'ui/performance-view.ui',
  'ui/process-row.ui',
  'ui/quit-process-dialog.ui',
  'ui/speedometer.ui',
  'ui/storage-actionbar.ui',
  'ui/storage-row-popover.ui',
  'ui/storage-view.ui',
  'ui/swap-speedometer.ui',
  'ui/window.ui',
)

gresource = 'org.gnome.Usage'

resources = gnome.compile_resources(
  gresource,
  gresource + '.gresource.xml',
  c_name: 'resources',
  dependencies: resource_data
)

schema_conf = configuration_data()
schema_conf.set('app-id', application_id)
configure_file(
  input: 'org.gnome.Usage.gschema.xml.in',
  output: '@BASENAME@',
  configuration: schema_conf,
  install: true,
  install_dir:  join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

desktop_conf = configuration_data()
desktop_conf.set('icon', application_id)
i18n.merge_file(
  type: 'desktop',
  input: configure_file(
    input: 'org.gnome.Usage.desktop.in.in',
    output: '@BASENAME@',
    configuration: desktop_conf
  ),
  output: '@0@.desktop'.format(application_id),
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

appdata_conf = configuration_data()
appdata_conf.set('app-id', application_id)
i18n.merge_file(
  input: configure_file(
    input: 'org.gnome.Usage.appdata.xml.in.in',
    output: '@BASENAME@',
    configuration: appdata_conf
  ),
  output: '@0@.appdata.xml'.format(application_id),
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_data(
  'icons/hicolor/scalable/apps/org.gnome.Usage.svg',
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps'),
  rename: '@0@.svg'.format(application_id)
)
