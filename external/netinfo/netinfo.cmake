include(ExternalProject)

ExternalProject_Add(
        netinfo
        DOWNLOAD_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cargo build COMMAND cargo build --release
        BINARY_DIR "${CMAKE_SOURCE_DIR}/external/netinfo/netinfo-ffi"
        INSTALL_COMMAND ""
        LOG_BUILD ON)