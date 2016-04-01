#!/bin/bash
CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
MAKE_FLAGS=-j$((CORE_COUNT + 2))

if [ "${ANDROID_BUILD_TOP}" != "" ]
then
    ret=`pwd | grep "${ANDROID_BUILD_TOP}"`
    if [ "$ret" != "" ]
    then
        ROOT_DIR=${ANDROID_BUILD_TOP}
    fi
fi
if [ "$ROOT_DIR" = "" ]
then
    ret=`cat Makefile 2>/dev/null | grep "include build/core/main.mk"`
    if [ "$ret" != "" ]
    then
        ROOT_DIR=`pwd`
    else
        echo "Do the source & lunch first or launch this from android build top directory"
        exit
    fi
fi

PATCH_DIR=${ROOT_DIR}/device/motorola/smi-patches

# Enable the temporary Makefile to abort the build in case of failure
cp ${PATCH_DIR}/Show-stopper.mk ${PATCH_DIR}/Android.mk

cd ${PATCH_DIR}

for proj in `find . -type d -name "*"`
do
    ls ${proj}/*.patch 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]
    then
        continue
    fi
    echo "Applying patches under ${proj}..."
    for patch_name in `ls ${PATCH_DIR}/${proj} --ignore-backups --ignore="*.bk"`
    do
        if [ -e ${ROOT_DIR}/${proj} ]; then
            cd ${ROOT_DIR}/${proj}
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
            git am -k -3 --ignore-space-change --ignore-whitespace ${patch}
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

# Extra patch for timezone
wget https://github.com/android/platform_bionic/raw/master/libc/zoneinfo/tzdata -P ${ROOT_DIR}/bionic/libc/zoneinfo/ -N

# All went well, disable the show-stopper Makefile
(\rm -f ${PATCH_DIR}/Android.mk)
