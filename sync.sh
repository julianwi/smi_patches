#!/bin/bash
PATCH_DIR=`pwd`
TOP_DIR=`pwd`/..
MAKE_FLAGS=-j$((CORE_COUNT + 2))
projectname=null

./clean_up_patches.sh
cd $TOP_DIR
repo sync
if [ "$1" = "reset" ]
then
   echo "resetting all repo's"
   repo forall -vc "git reset --hard"
fi
cd $PATCH_DIR
./apply_patch.sh
