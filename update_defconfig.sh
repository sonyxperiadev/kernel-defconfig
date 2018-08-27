export ANDROID_ROOT=../../../../../../../..
export KERNEL_TOP=$ANDROID_ROOT/kernel/sony/msm-4.9
export KERNEL_CFG=arch/arm64/configs/sony
export KERNEL_TMP=$ANDROID_ROOT/out/kernel-tmp
export BUILD="make O=$KERNEL_TMP ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)"

LOIRE="suzu kugo blanc"
TONE="dora kagura keyaki"
YOSHINO="lilac maple poplar"
NILE="discovery pioneer"
TAMA="akari apollo"

PLATFORMS="loire tone yoshino nile tama"
cd $KERNEL_TOP/kernel

for platform in $PLATFORMS; do \

case $platform in
loire)
    DEVICE=$LOIRE;
    DTBO="false";;
tone)
    DEVICE=$TONE;
    DTBO="false";;
yoshino)
    DEVICE=$YOSHINO;
    DTBO="false";;
nile)
    DEVICE=$NILE;
    DTBO="false";;
tama)
    DEVICE=$TAMA;
    DTBO="true";;
esac

for device in $DEVICE; do \
    rm -r $KERNEL_TMP
    ARCH=arm64 O=$KERNEL_TMP scripts/kconfig/merge_config.sh $KERNEL_CFG/base_$platform"_"$device\_defconfig $KERNEL_CFG/android-base.cfg $KERNEL_CFG/android-base-arm64.cfg $KERNEL_CFG/android-recommended.cfg $KERNEL_CFG/android-extra.cfg
    $BUILD savedefconfig
    mv $KERNEL_TMP/defconfig ./arch/arm64/configs/aosp_$platform"_"$device\_defconfig
done
done
