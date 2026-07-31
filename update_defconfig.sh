#!/bin/sh

find_build_top() {
    local dir=$PWD
    local max_depth=10
    while [ $max_depth -gt 0 ]; do
        if [ -e "$dir/.repo" ]; then
            realpath "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
        max_depth=$((max_depth - 1))
    done
    return 1
}

if [ -z "${ANDROID_BUILD_TOP}" ]; then
    if ! ANDROID_ROOT=$(find_build_top); then
        echo "Error: Could not find the Android root (no .repo found)" >&2
        exit 1
    fi
else
    ANDROID_ROOT=$(realpath "${ANDROID_BUILD_TOP}")
fi

KERNEL_TOP=${ANDROID_ROOT}/kernel/sony/msm-6.6
KERNEL_CFG=arch/arm64/configs/sony
KERNEL_TMP=${ANDROID_ROOT}/out/kernel-tmp
BUILD="make O=${KERNEL_TMP} ARCH=arm64 LLVM=1 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)"

echo "================================================="
echo "Your Environment:"
echo "ANDROID_ROOT: ${ANDROID_ROOT}"
echo "KERNEL_TOP  : ${KERNEL_TOP}"
echo "KERNEL_CFG  : ${KERNEL_CFG}"
echo "KERNEL_TMP  : ${KERNEL_TMP}"
ret=$(rm -rf ${KERNEL_TMP} 2>&1);
ret=$(mkdir -p ${KERNEL_TMP} 2>&1);
if [ ! -d ${KERNEL_TMP} ] ; then
    echo "Check your environment";
    echo "ERROR: ${ret}";
    exit 1;
fi

cd ${KERNEL_TOP}/kernel

# These values must be changed for forks!
KERNEL_DEFCONFIG_URL="https://github.com/sonyxperiadev/kernel-defconfig"
KERNEL_DEFCONFIG_BRANCH="aosp/K.P.4.0.r1"

KERNEL_DEFCONFIG_HEAD=$(git -C ${KERNEL_CFG} rev-parse HEAD)
read -r -d '' KERNEL_COMMIT_MESSAGE << EOM
arm64: configs: somc: update auto-generated defconfig for all platforms

This update is generated automatically by using the script "update_defconfig.sh"
which is maintained at this linked project below:
${KERNEL_DEFCONFIG_URL}/tree/${KERNEL_DEFCONFIG_BRANCH}
HEAD of the project used to prepare this commit:
${KERNEL_DEFCONFIG_URL}/tree/${KERNEL_DEFCONFIG_HEAD}
EOM

PLATFORMS="nagara columbia yodo elbe asahi"

for platform in $PLATFORMS; do \

    case $platform in
    nagara)
        SOC="waipio";;
    columbia)
        SOC="parrot";;
    yodo)
        SOC="kalama";;
    elbe)
        SOC="parrot";;
    asahi)
        SOC="pineapple";;
    esac

    echo "================================================="
    echo "SOC -> ${SOC} :: Platform -> ${platform}"
    echo "Running scripts/kconfig/merge_config.sh ..."
    ret=$(ARCH=arm64 LLVM=1 scripts/kconfig/merge_config.sh \
        -O "${KERNEL_TMP}" \
        ${KERNEL_CFG}/android-base.config \
        ${KERNEL_CFG}/gki_defconfig \
        ${KERNEL_CFG}/base_${SOC}_defconfig \
        ${KERNEL_CFG}/somc_${platform}_defconfig 2>&1);

    case "$ret" in
        *"error"*|*"ERROR"*|*"Exit"*) echo "ERROR: $ret"; exit 1;;
    esac
    echo "Building new defconfig ..."
    ret=$(${BUILD} savedefconfig 2>&1);
    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac
    mv $KERNEL_TMP/defconfig ./arch/arm64/configs/aosp_${platform}_defconfig
done

echo "================================================="
echo "Done!"
rm -rf $KERNEL_TMP

echo "You can now commit the updated defconfig with the following as the commit message:"
echo "${KERNEL_COMMIT_MESSAGE}"
