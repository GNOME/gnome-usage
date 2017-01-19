find_program(RUSTC_EXECUTABLE rustc)
if(${RUSTC_EXECUTABLE} MATCHES "NOTFOUND")
    message( FATAL_ERROR "You haven't rust, please install it!" )
endif()

find_program(CARGO_EXECUTABLE cargo)
if(${CARGO_EXECUTABLE} MATCHES "NOTFOUND")
    message( FATAL_ERROR "You haven't cargo, please install it!" )
endif()

include(ExternalProject)

ExternalProject_Add(
        netinfo
        DOWNLOAD_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cargo build COMMAND cargo build --release
        BINARY_DIR "${CMAKE_SOURCE_DIR}/external/netinfo/netinfo-ffi"
        INSTALL_COMMAND ""
        LOG_BUILD ON)