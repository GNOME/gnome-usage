resource_data = files(
  'interface/adwaita.css',
  'ui/header-bar.ui',
  'ui/memory-speedometer.ui',
  'ui/no-results-found-view.ui',
  'ui/performance-view.ui',
  'ui/process-row.ui',
  'ui/quit-process-dialog.ui',
  'ui/speedometer.ui',
  'ui/storage-actionbar.ui',
  'ui/storage-view.ui',
  'ui/swap-speedometer.ui'
)

gresource = 'org.gnome.Usage'
datadir = '.'

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

if get_option('profile') == 'development'
  profile = 'Devel'
  name_suffix = ' (Development Snapshot)'
else
  profile = ''
  name_suffix = ''
endif

application_id = 'org.gnome.Usage@0@'.format(profile)

foreach icon_size: ['16x16', '22x22', '24x24', '32x32', '48x48', '512x512']
  icondir = join_paths('icons', 'hicolor', icon_size, 'apps')

  install_data(
    join_paths(icondir, 'org.gnome.Usage.png'),
    install_dir: join_paths(datadir, icondir),
    rename: '@0@.png'.format(application_id)
  )
endforeach

icondir = join_paths('icons', 'hicolor', 'symbolic', 'apps')

install_data(
  join_paths(icondir, 'org.gnome.Usage-symbolic.svg'),
  install_dir: join_paths(datadir, icondir),
  rename: '@0@-symbolic.svg'.format(application_id)
)

desktop_conf = configuration_data()
desktop_conf.set('icon', application_id)
desktop = i18n.merge_file(
  'desktop',
  input: configure_file(
    input: files('org.gnome.Usage.desktop.in.in'),
    output: 'org.gnome.Usage.desktop.in',
    configuration: desktop_conf
  ),
  output: '@0@.desktop'.format(application_id),
  install: true,
  install_dir: desktopdir,
  po_dir: po_dir,
  type: 'desktop'
)

appdata_conf = configuration_data()
appdata_conf.set('appid', application_id)
appdata = i18n.merge_file(
  'appdata',
  input: configure_file(
    input: files('org.gnome.Usage.appdata.xml.in.in'),
    output: 'org.gnome.Usage.appdata.xml.in',
    configuration: appdata_conf
  ),
  output: '@0@.appdata.xml'.format(application_id),
  install: true,
  install_dir: join_paths(datadir, 'metainfo'),
  po_dir: po_dir
)

service_conf = configuration_data()
service_conf.set('appid', application_id)
service_conf.set('bindir', join_paths(prefix, bindir))
configure_file(
  input: 'org.gnome.Usage.service.in',
  output: '@0@.service'.format(application_id),
  configuration: service_conf,
  install_dir: servicedir
)

search_provider_conf = configuration_data()
search_provider_conf.set('appid', application_id)
search_provider_conf.set('profile', profile)
configure_file(
  configuration: search_provider_conf,
  input: files('org.gnome.Usage.search-provider.ini.in'),
  install_dir: join_paths(datadir, 'gnome-shell', 'search-providers'),
  output: '@0@.search-provider.ini'.format(application_id)
)
