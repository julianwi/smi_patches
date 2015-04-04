#!/bin/bash
PATCH_DIR=`pwd`
TOP_DIR=`pwd`/..
MAKE_FLAGS=-j$((CORE_COUNT + 2))
projectname=null

./clean_up_patches.sh
cd $TOP_DIR
repo sync
cd $PATCH_DIR
./apply_patch.sh
