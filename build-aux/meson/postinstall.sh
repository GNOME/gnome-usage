#!/bin/sh

# Package managers set this so we don't need to run
if [ -z "$DESTDIR" ] && [ $# -gt 0 ]; then
  echo Compiling GSettings schemas...
  glib-compile-schemas $1/glib-2.0/schemas

  echo Updating desktop database...
  update-desktop-database -q $1/applications
fi
