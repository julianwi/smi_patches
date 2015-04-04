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
    for patch_name in `ls ${PATCH_DIR}/${proj}`
    do
        if [ -e ${TOP_DIR}/${proj} ]; then
            cd ${TOP_DIR}/${proj}
        else
            echo "no source code, skip dir: ${TOP_DIR}/${proj}"
            break
        fi

        patch=${PATCH_DIR}/${proj}/${patch_name}
        change_id=`grep -w "^Change-Id:" ${patch} | awk '{print $2}'`
        ret=`git log | grep -w "^    Change-Id: ${change_id}" 2>/dev/null`
        if [ "${ret}" == "" ]
        then
            echo "Applying ${patch_name}"
            patch -p1 < ${patch}
            if [ $? -ne 0 ]
            then
                echo "Failed at ${proj}"
                echo "Abort..."
                git am --abort
                exit
            fi
        else
            echo "Applying ${patch_name}"
            echo "Applied, ignore and continue..."
        fi
    done
    cd ${PATCH_DIR}
done
