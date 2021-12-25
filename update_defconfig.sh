cd ../../../../../../../..
ls
export ANDROID_ROOT=$(pwd)
export KERNEL_TOP=$ANDROID_ROOT/kernel/sony/msm-5.4/
export KERNEL_CFG=arch/arm64/configs/sony
export KERNEL_TMP=$ANDROID_ROOT/out/kernel-tmp
#export CROSS_COMPILE=prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export BUILD="make O=$KERNEL_TMP ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)"

cd $KERNEL_TOP/kernel

# These values must be changed for forks!
KERNEL_DEFCONFIG_URL="https://github.com/sonyxperiadev/kernel-defconfig"
KERNEL_DEFCONFIG_BRANCH="aosp/LA.UM.9.14.r1"

KERNEL_DEFCONFIG_HEAD=$(git -C ${KERNEL_CFG} rev-parse HEAD)
read -r -d '' KERNEL_COMMIT_MESSAGE << EOM
arm64: configs: somc: update auto-generated defconfig for all platforms

This update is generated automatically by using the script "update_defconfig.sh" which is maintained at this linked project below:
${KERNEL_DEFCONFIG_URL}/tree/${KERNEL_DEFCONFIG_BRANCH}
HEAD of the project used to prepare this commit:
${KERNEL_DEFCONFIG_URL}/tree/${KERNEL_DEFCONFIG_HEAD}
EOM

SAGAMI="pdx215"

PLATFORMS="sagami"

for platform in $PLATFORMS; do \

case $platform in
sagami)
    DEVICE=$SAGAMI;
    SOC="sm8350";;
esac

echo "================================================="
echo "Your Environment:"
echo "ANDROID_ROOT: ${ANDROID_ROOT}"
echo "KERNEL_TOP  : ${KERNEL_TOP}"
echo "KERNEL_CFG  : ${KERNEL_CFG}"
echo "KERNEL_TMP  : ${KERNEL_TMP}"
for device in $DEVICE; do \
    ret=$(rm -rf ${KERNEL_TMP} 2>&1);
    ret=$(mkdir -p ${KERNEL_TMP} 2>&1);
    if [ ! -d ${KERNEL_TMP} ] ; then
        echo "Check your environment";
        echo "ERROR: ${ret}";
        exit 1;
    fi
    echo "================================================="
    echo "SOC -> ${SOC} :: Platform -> ${platform} :: Device -> $device"
    echo "Running scripts/kconfig/merge_config.sh ..."
    ret=$(ARCH=arm64 scripts/kconfig/merge_config.sh \
        -O "${KERNEL_TMP}" \
        ${KERNEL_CFG}/android-base.config \
        ${KERNEL_CFG}/android-recommended.config \
        ${KERNEL_CFG}/android-recommended-arm64.config \
        ${KERNEL_CFG}/base_${SOC}_defconfig \
        ${KERNEL_CFG}/base_${platform}"_"${device}\_defconfig \
        ${KERNEL_CFG}/android-extra.config 2>&1);



    case "$ret" in
        *"error"*|*"ERROR"*|*"Exit"*) echo "ERROR: $ret"; exit 1;;
    esac
    echo "Building new defconfig ..."
    ret=$(${BUILD} savedefconfig 2>&1);
    case "$ret" in
        *"error"*|*"ERROR"*) echo "ERROR: $ret"; exit 1;;
    esac
    mv $KERNEL_TMP/defconfig ./arch/arm64/configs/aosp_$platform"_"$device\_defconfig
done
done

echo "================================================="
echo "Done!"
rm -rf $KERNEL_TMP

echo "You can now commit the updated defconfig with the following as the commit message:"
echo "${KERNEL_COMMIT_MESSAGE}"

unset ANDROID_ROOT
unset KERNEL_TOP
unset KERNEL_CFG
unset KERNEL_TMP
unset BUILD
