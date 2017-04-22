gnome_module = import('gnome')

resources = gnome_module.compile_resources('org.gnome.Usage',
                                           'org.gnome.Usage.gresource.xml',
                                           source_dir: 'data',
                                           c_name: 'resources')

install_data('org.gnome.Usage.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')
install_data('org.gnome.Usage.desktop', install_dir : get_option('datadir') + '/applications')
