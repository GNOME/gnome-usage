### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/gnome-usage")
set (GETTEXT_PACKAGE "gnome-usage")
set (RELEASE_NAME "gnome-usage")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "0.2.7")
set (TESTSRCDIR "${CMAKE_SOURCE_DIR}")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/Config.vala.cmake ${CMAKE_BINARY_DIR}/src/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
set (VERSION "0.2.7")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.34" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} posix)
set (VALA_PACKAGES ${VALA_PACKAGES} atk)
set (VALA_PACKAGES ${VALA_PACKAGES} cairo)
set (VALA_PACKAGES ${VALA_PACKAGES} gdk-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gdk-pixbuf-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gee-0.8)
set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} glib-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gobject-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gtk+-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} pango)
set (VALA_PACKAGES ${VALA_PACKAGES} x11)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} application.vala)
set (APP_SOURCES ${APP_SOURCES} color-rectangle.vala)
set (APP_SOURCES ${APP_SOURCES} cookie-graph.vala)
set (APP_SOURCES ${APP_SOURCES} cpu-graph-table.vala)
set (APP_SOURCES ${APP_SOURCES} cpu-graph.vala)
set (APP_SOURCES ${APP_SOURCES} cpu-sub-view.vala)
set (APP_SOURCES ${APP_SOURCES} data-view.vala)
set (APP_SOURCES ${APP_SOURCES} disk-sub-view.vala)
set (APP_SOURCES ${APP_SOURCES} gnome-usage.vala)
set (APP_SOURCES ${APP_SOURCES} graph-block-row.vala)
set (APP_SOURCES ${APP_SOURCES} graph-block.vala)
set (APP_SOURCES ${APP_SOURCES} graph-box.vala)
set (APP_SOURCES ${APP_SOURCES} graph-stack-switcher.vala)
set (APP_SOURCES ${APP_SOURCES} graph-switcher-button.vala)
set (APP_SOURCES ${APP_SOURCES} header-bar.vala)
set (APP_SOURCES ${APP_SOURCES} memory-graph-table.vala)
set (APP_SOURCES ${APP_SOURCES} memory-graph.vala)
set (APP_SOURCES ${APP_SOURCES} memory-sub-view.vala)
set (APP_SOURCES ${APP_SOURCES} network-sub-view.vala)
set (APP_SOURCES ${APP_SOURCES} performance-view.vala)
set (APP_SOURCES ${APP_SOURCES} power-view.vala)
set (APP_SOURCES ${APP_SOURCES} process-dialog.vala)
set (APP_SOURCES ${APP_SOURCES} process-list-box.vala)
set (APP_SOURCES ${APP_SOURCES} process-row.vala)
set (APP_SOURCES ${APP_SOURCES} settings.vala)
set (APP_SOURCES ${APP_SOURCES} storage-view.vala)
set (APP_SOURCES ${APP_SOURCES} sub-process-list-box.vala)
set (APP_SOURCES ${APP_SOURCES} sub-process-sub-row.vala)
set (APP_SOURCES ${APP_SOURCES} system-monitor.vala)
set (APP_SOURCES ${APP_SOURCES} test-netinfo.vala)
set (APP_SOURCES ${APP_SOURCES} view.vala)
set (APP_SOURCES ${APP_SOURCES} window.vala)

set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/vapis/better.vapi)
set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/vapis/egg.vapi)
set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/vapis/glibtop.vapi)
set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/vapis/netinfo.vapi)
set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/vapis/rg.vapi)


if ((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo"))
	set(COMPILE_OPTIONS ${COMPILE_OPTIONS} "-g")
endif()

include_directories (AFTER ../external/egg )
include_directories (AFTER ../external/netinfo )
include_directories (AFTER ../external/rg )
include_directories (AFTER /usr/include/libgtop-2.0 )
include_directories (AFTER . )

vala_precompile(VALA_C gnome-usage
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
CUSTOM_VAPIS
	${CUSTOM_VAPIS_LIST}
)

set (VALA_C ${VALA_C} ../external/egg/egg-animation.c)
set (VALA_C ${VALA_C} ../external/egg/egg-binding-group.c)
set (VALA_C ${VALA_C} ../external/egg/egg-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-centering-bin.c)
set (VALA_C ${VALA_C} ../external/egg/egg-column-layout.c)
set (VALA_C ${VALA_C} ../external/egg/egg-counter.c)
set (VALA_C ${VALA_C} ../external/egg/egg-date-time.c)
set (VALA_C ${VALA_C} ../external/egg/egg-empty-state.c)
set (VALA_C ${VALA_C} ../external/egg/egg-entry-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-file-chooser-entry.c)
set (VALA_C ${VALA_C} ../external/egg/egg-frame-source.c)
set (VALA_C ${VALA_C} ../external/egg/egg-heap.c)
set (VALA_C ${VALA_C} ../external/egg/egg-list-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-menu-manager.c)
set (VALA_C ${VALA_C} ../external/egg/egg-pill-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-priority-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-radio-box.c)
set (VALA_C ${VALA_C} ../external/egg/egg-scrolled-window.c)
set (VALA_C ${VALA_C} ../external/egg/egg-search-bar.c)
set (VALA_C ${VALA_C} ../external/egg/egg-settings-flag-action.c)
set (VALA_C ${VALA_C} ../external/egg/egg-settings-sandwich.c)
set (VALA_C ${VALA_C} ../external/egg/egg-signal-group.c)
set (VALA_C ${VALA_C} ../external/egg/egg-simple-label.c)
set (VALA_C ${VALA_C} ../external/egg/egg-simple-popover.c)
set (VALA_C ${VALA_C} ../external/egg/egg-slider.c)
set (VALA_C ${VALA_C} ../external/egg/egg-state-machine-buildable.c)
set (VALA_C ${VALA_C} ../external/egg/egg-state-machine.c)
set (VALA_C ${VALA_C} ../external/egg/egg-task-cache.c)
set (VALA_C ${VALA_C} ../external/egg/egg-three-grid.c)
set (VALA_C ${VALA_C} ../external/egg/egg-widget-action-group.c)
set (VALA_C ${VALA_C} ../external/rg/rg-column.c)
set (VALA_C ${VALA_C} ../external/rg/rg-cpu-graph.c)
set (VALA_C ${VALA_C} ../external/rg/rg-cpu-table.c)
set (VALA_C ${VALA_C} ../external/rg/rg-graph.c)
set (VALA_C ${VALA_C} ../external/rg/rg-line-renderer.c)
set (VALA_C ${VALA_C} ../external/rg/rg-renderer.c)
set (VALA_C ${VALA_C} ../external/rg/rg-ring.c)
set (VALA_C ${VALA_C} ../external/rg/rg-stacked-renderer.c)
set (VALA_C ${VALA_C} ../external/rg/rg-table.c)
set (VALA_C ${VALA_C} better-box.c)

add_executable(gnome-usage ${VALA_C})
target_link_libraries( gnome-usage gmodule-2.0 m rt gtop-2.0 ${CMAKE_SOURCE_DIR}/external/netinfo/libnetinfo.a pthread dl )


install(TARGETS
	gnome-usage
RUNTIME DESTINATION
	${CMAKE_INSTALL_BINDIR}
)
if(HAVE_VALADOC)
	valadoc(gnome-usage
		${CMAKE_BINARY_DIR}/valadoc/gnome-usage
		${APP_SOURCES}
	PACKAGES
		${VALA_PACKAGES}
	CUSTOM_VAPIS
		${CUSTOM_VAPIS_LIST}
	)
	install(DIRECTORY
		${CMAKE_BINARY_DIR}/valadoc
	DESTINATION
		${CMAKE_INSTALL_DATAROOTDIR}/doc/gnome-usage
	)
endif()
