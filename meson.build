project(
  'gnome-usage', ['vala', 'c'],
  version: '3.33.2',
  license: 'GPL3',
  meson_version: '>= 0.37.0'
)

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

glib_dep = dependency('glib-2.0', version : '>=2.38')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gtk_dep = dependency('gtk+-3.0', version : '>=3.20.10')
libdazzle_dep = dependency('libdazzle-1.0', version : '>=3.30')
libgtop_dep = dependency('libgtop-2.0', version : '>= 2.34.0')
libhandy_dep = dependency('libhandy-0.0', version : '>=0.0.10')
tracker_dep = dependency('tracker-sparql-2.0')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments (
  '-DHANDY_USE_UNSTABLE_API',
  language: 'c'
)

po_dir = join_paths(meson.source_root(), 'po')
vapi_dir = join_paths (meson.source_root (), 'vapi')

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script(
  join_paths('build-aux', 'meson', 'postinstall.sh'),
  join_paths(get_option('prefix'), get_option('datadir'))
)
