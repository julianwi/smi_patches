#!/bin/bash
PATCH_DIR=`pwd`
TOP_DIR=`pwd`/..
CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
MAKE_FLAGS=-j$((CORE_COUNT + 2))
projectname=null

for proj in `find . -type d -name "*"`
do
    ls ${proj}/*.patch 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]
    then
        continue
    fi
    echo "Applying patches under ${proj}..."
    for patch_name in `ls ${PATCH_DIR}/${proj} --ignore-backups`
    do
        if [ -e ${TOP_DIR}/${proj} ]; then
            cd ${TOP_DIR}/${proj}
        else
            echo "no source code, skip dir: ${TOP_DIR}/${proj}"
            break
        fi

        patch=${PATCH_DIR}/${proj}/${patch_name}
            echo "Applying ${patch_name}"
            patch -p1 < ${patch}
            if [ $? -ne 0 ]
            then
                echo "Failed at ${proj}"
                echo "Abort..."
                git am --abort
                exit
            fi
    done
    cd ${PATCH_DIR}
done
