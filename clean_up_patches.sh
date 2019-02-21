#!/bin/bash
PATCH_DIR=device/motorola/smi-patches
cd ../../../
PATCHED_PROJECTS=$(
  for i in ${PATCH_DIR}
  do
    (
      cd $i
      find . -type d -print
    )
  done | sort -u |
    while read _dir
    do
      if [ -d $_dir/.git ]; then
        echo $_dir
      fi
    done
)

repo forall $PATCHED_PROJECTS -c git reset --hard github/lineage-16.0
repo forall $PATCHED_PROJECTS -c git clean -d -f -x

echo
echo Repo status for $PATCHED_PROJECTS
repo status $PATCHED_PROJECTS
cd ${PATCH_DIR}
exit
