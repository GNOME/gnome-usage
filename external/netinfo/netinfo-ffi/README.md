Netinfo-FFI
===========

This is the C foreign function interface, so that you can
call [netinfo](https://github.com/ChangSpivey/netinfo) from C. Netinfo allows
you to group the TCP/UDP network usage by process without a special kernel
module.

[Documentation of Rust library](https://docs.rs/netinfo)

Please leave feedback, bug reports and feature request that are not
strictly related to the FFI at the
main [netinfo](https://github.com/ChangSpivey/netinfo) library.


How to build
--------------
Install the latest Cargo/Rust:

```bash
$ git clone https://github.com/ChangSpivey/netinfo-ffi
$ cd netinfo-ffi
$ cargo build --release
```

There is now a static library `./target/release/libnetinfo.a` and a dynamic
library `./target/release/libnetinfo.so`.
