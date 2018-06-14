project(
  'gnome-usage', ['vala', 'c'],
  version: '3.28.0',
  license: 'GPL3',
  meson_version: '>= 0.37.0'
)

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

glib_dep = dependency('glib-2.0', version : '>=2.38')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gtk_dep = dependency('gtk+-3.0', version : '>=3.20.10')

gnome = import('gnome')
i18n = import('i18n')

po_dir = join_paths(meson.source_root(), 'po')
vapi_dir = join_paths (meson.source_root (), 'vapi')
datadir = 'data'

subdir('data')
subdir('po')
subdir('external')
subdir('src')

meson.add_install_script(
  join_paths('build-aux', 'meson', 'postinstall.sh'),
  join_paths(get_option('prefix'), get_option('datadir'))
)

if get_option('profile') == 'development'
  profile = 'Devel'
  name_suffix = ' (Development Snapshot)'
else
  profile = ''
  name_suffix = ''
endif

application_id = 'org.gnome.Usage@0@'.format(profile)

conf = configuration_data ()
conf.set_quoted('PROFILE', profile)
conf.set_quoted('APPLICATION_ID', application_id)
conf.set_quoted('NAME_SUFFIX', name_suffix)

config_h = declare_dependency(
  sources: vcs_tag(
    command: ['git', 'rev-parse', '--short', 'HEAD'],
    fallback: get_option('profile') != 'default'? 'devel' : 'stable',
    input: configure_file(
      output: 'config.h.in',
      configuration: conf
    ),
    output: 'config.h'
  )
)
