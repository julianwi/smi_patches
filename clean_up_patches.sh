#!/bin/bash

PATCH_DIR=device/motorola/smi-patches
cd ../../../
PATCHED_PROJECTS=$(
  for i in ${PATCH_DIR}
  do
    (
      cd $i
      find . -path ./external/ffmpeg -prune -o -type d -print
    )
  done | sort -u |
    while read _dir
    do
      if [ -d $_dir/.git ]; then
        echo $_dir
      fi
    done
)

repo forall $PATCHED_PROJECTS -c git reset --hard github/cm-11.0
repo forall $PATCHED_PROJECTS -c git clean -d -f -x
# For CM13 and other projects
repo forall external/ffmpeg -c git reset --hard github/cm-13.0
repo forall external/ffmpeg -c git clean -d -f -x

echo
echo Repo status for $PATCHED_PROJECTS
repo status $PATCHED_PROJECTS
cd ${PATCH_DIR}
exit
