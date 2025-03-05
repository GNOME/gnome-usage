project(
  'gnome-usage', ['vala', 'c'],
  version: '48.rc',
  license: 'GPL3',
  meson_version: '>= 0.50.0'
)

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

# Development versions of Usage might use features from pre-release
# versions of its dependencies if their release schedules align,
# esp. when following GNOME's.
if get_option('profile') == 'development'
  add_project_arguments(
    '--disable-since-check',
    language: 'vala'
  )
endif

gee_dep = dependency('gee-0.8')
glib_dep = dependency('glib-2.0', version : '>=2.38')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0', version : '>=2.74')
gio_unix_dep = dependency('gio-unix-2.0')
gtk_dep = dependency('gtk4', version : '>=4.11.3')
json_dep = dependency('json-glib-1.0')
libgtop_dep = dependency('libgtop-2.0', version : '>= 2.34.0')
libnm_dep = dependency('libnm', version : '>= 1.44.0')
libadwaita_dep = dependency('libadwaita-1', version : '>=1.6')
tinysparql_dep = dependency('tinysparql-3.0')

gnome = import('gnome')
i18n = import('i18n')

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
