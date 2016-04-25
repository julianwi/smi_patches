#!/bin/bash
CM13=(./external/ffmpeg) # ./external/stagefright-plugins)
PATCH_DIR=device/motorola/smi-patches
cd ../../../
PATCHED_PROJECTS=$(
  for i in ${PATCH_DIR}
  do
    (
      cd $i
      find . -path ${CM13[0]} -prune -o -print
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
repo forall $CM13 -c git reset --hard github/cm-13.0
repo forall $CM13 -c git clean -d -f -x

echo
echo Repo status for $PATCHED_PROJECTS ${CM13[*]}
repo status $PATCHED_PROJECTS ${CM13[*]}
cd ${PATCH_DIR}
exit
