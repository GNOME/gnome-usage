project('gnome-usage', ['vala', 'c'], version : '0.4.5')

cc = meson.get_compiler('c')

glib = dependency('glib-2.0', version : '>=2.38')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
gtk = dependency('gtk+-3.0', version : '>=3.20.10')
gtop = dependency('libgtop-2.0', version : '>=2.34.0')
accountsservice = dependency('accountsservice', version: '>= 0.6.40')
math = cc.find_library('m')

subdir('data')
subdir('po')
subdir('external')
subdir('src')

meson.add_install_script ('build-aux/meson/postinstall.sh')
