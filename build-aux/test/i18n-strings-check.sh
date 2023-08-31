#!/bin/sh

srcdirs="src"
uidirs="data/ui"

# find source files that contain gettext keywords
vala_files="$(grep -lR --include='*.vala' '\(gettext\|[^I_)]_\)(' $srcdirs)"

# find ui files that contain translatable string
ui_files="$(grep -lRi --include='*.ui' 'translatable="[ty1]' $uidirs)"

files="$vala_files $ui_files"

# filter out excluded files
if [ -f po/POTFILES.skip ]; then
  files="$(for f in $files; do ! grep -q "^$f$" po/POTFILES.skip && echo "$f"; done)"
fi

# Test 1: find all files that are missing from POTFILES.in
missing="$(for f in $files; do ! grep -q "^$f$" po/POTFILES.in && echo "$f"; done)"
if [ ${#missing} -ne 0 ]; then
  echo >&2 "The following files are missing from po/POTFILES.in:"
  for f in ${missing}; do
    echo "  $f" >&2
  done
  echo >&2
  exit 1
fi

# Test 2: find all Vala files that miss a corresponding .c file in POTFILES.skip
vala_c_files="$(for f in $vala_files; do echo "${f%.vala}.c"; done)"
vala_c_files_missing="$(for f in ${vala_c_files}; do ! grep -q "^$f$" po/POTFILES.skip && echo "$f"; done)"
if [ ${#vala_c_files_missing} -ne 0 ]; then
  echo >&2 "The following files are missing from po/POTFILES.skip:"
  for f in ${vala_c_files_missing}; do
    echo "  $f" >&2
  done
  echo >&2
  exit 1
fi
