add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )

include_directories(${CMAKE_SOURCE_DIR}/external/egg)


add_library(rg STATIC realtime-graphs.h
    rg-column.c
    rg-column.h
    rg-column-private.h
    rg-cpu-graph.c
    rg-cpu-graph.h
    rg-cpu-table.c
    rg-cpu-table.h
    rg-graph.c
    rg-graph.h
    rg-line-renderer.c
    rg-line-renderer.h
    rg-stacked-renderer.c
    rg-stacked-renderer.h
    rg-renderer.c
    rg-renderer.h
    rg-ring.c
    rg-ring.h
    rg-table.c
    rg-table.h )
