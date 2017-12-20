gnome_module = import('gnome')

resources = gnome_module.compile_resources('org.gnome.Usage',
                                           'org.gnome.Usage.gresource.xml',
                                           source_dir: 'data',
                                           c_name: 'resources')

install_data('org.gnome.Usage.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')

i18n.merge_file(
  'desktop-file',
  type: 'desktop',
  input: 'org.gnome.Usage.desktop.in',
  output: 'org.gnome.Usage.desktop',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
  'appdata-file',
  input: 'org.gnome.Usage.appdata.xml.in',
  output: 'org.gnome.Usage.appdata.xml',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_subdir(
  'icons/hicolor',
  install_dir: join_paths(get_option('datadir'), 'icons')
)
