project(
  'gnome-usage', ['vala', 'c'],
  version: '3.38.0',
  license: 'GPL3',
  meson_version: '>= 0.50.0'
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
libhandy_dep = dependency('libhandy-1', version : '>= 1.0.0', required: false)
tracker_dep = dependency('tracker-sparql-3.0')

if not libhandy_dep.found()
  libhandy_subproj = subproject(
    'libhandy',
    default_options: [
      'examples=false',
      'glade_catalog=disabled',
      'tests=false',
    ]
  )

  # When using libhandy as subproject, make sure we get the VAPI file
  libhandy_dep = declare_dependency(
    dependencies: [
      libhandy_subproj.get_variable('libhandy_dep'),
      libhandy_subproj.get_variable('libhandy_vapi'),
    ]
  )

  libhandy_vapidir = join_paths(meson.build_root(), 'subprojects', 'libhandy', 'src')
else
  libhandy_vapidir = ''
endif

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments (
  '-DHANDY_USE_UNSTABLE_API',
  language: 'c'
)

add_project_arguments (
  # FIXME Drop once we depend on libhandy 1.0.
  '--disable-since-check',
  language: 'vala'
)

po_dir = join_paths(meson.source_root(), 'po')
vapi_dir = join_paths (meson.source_root (), 'vapi')

vapi_dirs = [ '--vapidir=@0@'.format(vapi_dir) ]
if libhandy_vapidir != ''
  vapi_dirs += '--vapidir=@0@'.format(libhandy_vapidir)
endif

if get_option('profile') == 'development'
  profile = 'Devel'
  name_suffix = ' (Development)'
else
  profile = ''
  name_suffix = ''
endif

application_id = 'org.gnome.Usage@0@'.format(profile)


subdir('data')
subdir('po')
subdir('src')

meson.add_install_script(
  join_paths('build-aux', 'meson', 'postinstall.sh'),
  join_paths(get_option('prefix'), get_option('datadir'))
)
