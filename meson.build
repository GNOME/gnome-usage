project(
  'gnome-usage', ['vala', 'c'],
  version: '3.38.1',
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

base_id = 'org.gnome.Usage'
resource_path = '/org/gnome/Usage/'

if get_option('profile') == 'development'
  profile = 'Devel'
  version_suffix = '-devel'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD', check: false).stdout().strip()
  if vcs_tag != ''
    version_suffix = '-@0@'.format(vcs_tag)
  endif
else
  profile = ''
  version_suffix = ''
endif

if profile != ''
  application_id = '@0@@1@'.format(base_id, profile)
else
  application_id = base_id
endif

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script(
  join_paths('build-aux', 'meson', 'postinstall.sh'),
  join_paths(get_option('prefix'), get_option('datadir'))
)
