Name: gnome-usage
Version: 0.3.7
Release: 1
License: GPLv3
Summary: New GNOME Usage!

BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: vala
BuildRequires: glibc-headers
BuildRequires: atk-devel
BuildRequires: cairo-devel
BuildRequires: gtk3-devel
BuildRequires: gdk-pixbuf2-devel
BuildRequires: libgee-devel
BuildRequires: glib2-devel
BuildRequires: pango-devel
BuildRequires: libX11-devel
BuildRequires: cmake
BuildRequires: gettext
BuildRequires: pkgconfig
BuildRequires: make
BuildRequires: intltool
BuildRequires: libgtop2

Requires: atk
Requires: glib2
Requires: cairo
Requires: gtk3
Requires: pango
Requires: gdk-pixbuf2
Requires: cairo-gobject
Requires: libgee
Requires: libX11

%description
New GNOME Usage!
.

%files
%{_bindir}/gnome-usage
%{_datadir}/applications/org.gnome.Usage.desktop
%{_datadir}/gnome-usage/adwaita.css
%{_datadir}/gnome-usage/adwaita-dark.css
%{_datadir}/gnome-usage/CMakeLists.txt

%build
mkdir -p ${RPM_BUILD_DIR}
cd ${RPM_BUILD_DIR}; cmake -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF -DICON_UPDATE=OFF ../..
make -C ${RPM_BUILD_DIR}

%install
make install -C ${RPM_BUILD_DIR} DESTDIR=%{buildroot}

%post
setcap cap_net_raw,cap_net_admin=eip %{_bindir}/gnome-usage

%clean
rm -rf %{buildroot}

