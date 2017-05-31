gnome_module = import('gnome')

resources = gnome_module.compile_resources('org.gnome.Usage',
                                           'org.gnome.Usage.gresource.xml',
                                           source_dir: 'data',
                                           c_name: 'resources')

install_data('org.gnome.Usage.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')
install_data('org.gnome.Usage.desktop', install_dir : get_option('datadir') + '/applications')

install_data('icons/16x16/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/16x16/apps']))
install_data('icons/22x22/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/22x22/apps']))
install_data('icons/24x24/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/24x24/apps']))
install_data('icons/32x32/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/32x32/apps']))
install_data('icons/48x48/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/48x48/apps']))
install_data('icons/512x512/org.gnome.Usage.png', install_dir: join_paths([get_option('datadir'), 'icons/hicolor/512x512/apps']))
