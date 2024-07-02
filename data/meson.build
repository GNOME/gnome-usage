schema_conf = configuration_data()
schema_conf.set('app-id', application_id)
configure_file(
  input: '@0@.gschema.xml.in'.format(base_id),
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
    input: '@0@.desktop.in.in'.format(base_id),
    output: '@BASENAME@',
    configuration: desktop_conf
  ),
  output: '@0@.desktop'.format(application_id),
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

metainfo_conf = configuration_data()
metainfo_conf.set('app-id', application_id)
metainfo = i18n.merge_file(
  input: configure_file(
    input: '@0@.metainfo.xml.in.in'.format(base_id),
    output: '@BASENAME@',
    configuration: metainfo_conf
  ),
  output: '@0@.metainfo.xml'.format(application_id),
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)
# install metainfo a second time to base_id location to work around
# https://gitlab.gnome.org/GNOME/vala/-/issues/804 TODO: don't
# see data/org.gnome.Usage.gresource.xml, src/application.vala
if application_id != base_id
  metainfo = i18n.merge_file(
    input: configure_file(
      input: '@0@.metainfo.xml.in.in'.format(base_id),
      output: '@BASENAME@',
      configuration: metainfo_conf
    ),
    output: '@0@.metainfo.xml'.format(base_id),
    po_dir: po_dir,
    install: false
  )
endif

resources_conf = configuration_data()
resources_conf.set('app-id', application_id)
resources_conf.set('base-id', base_id)
resources = gnome.compile_resources(
  base_id,
  '@0@.gresource.xml'.format(base_id),
  c_name: 'resources',
  dependencies: [metainfo]
)

install_data(
  'icons/hicolor/scalable/apps/@0@.svg'.format(application_id),
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps'),
  rename: '@0@.svg'.format(application_id)
)
