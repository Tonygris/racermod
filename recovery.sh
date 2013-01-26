#!/bin/bash
#
# Copyright 2012 - mikeioannina
#

# Move gen2 recovery.img to racermod folder
cd ~/android/cm7

echo "Moving recovery.imp to racermod folder..."
rm ~/android/racermod/cm7/recovery/recovery/gen2_recovery.img
mv ./out/target/product/mooncake/recovery.img ~/android/racermod/cm7/recovery/recovery/gen2_recovery.img
echo "Done!"



# Create temp dir & integrate gen check script
cd ~/android/racermod/cm7/recovery

echo "Creating temp folder..."
mkdir temp
echo "Done!"

echo "Copying META-INF & recovery folder..."
cp -r recovery temp/recovery
cp -r META-INF temp/META-INF
echo "Done!"

# Unpack gen2_recovery.img to get the ramdisk
echo "Unpacking gen2_recovery.img to get the ramdisk..."
rm ramdisk.gz
../../split_bootimg.pl temp/recovery/gen2_recovery.img
echo "Done!"

# Delete gen2 zImage & rename ramdisk
rm gen2_recovery.img-kernel
mv gen2_recovery.img-ramdisk.gz ramdisk.gz



# Build gen1 kernel and create gen1_recovery.img
cd ~/android/cm7/kernel/zte/msm7x27

# Setup enviroment
export ARCH=arm
export CROSS_COMPILE="ccache $CCOMPILER7"

# Mooncake gen1
echo "Cleaning up & setting .version..."
make clean
rm .version
echo "Done!"

echo "Loading gen1 defconfig..."
make cyanogen_mooncake_gen1_defconfig
echo "Done!"

echo "Compiling kernel..."
make -j4
echo "Done!"

echo "Copying zImage..."
rm ~/android/racermod/cm7/recovery/gen1zImage
cp ./arch/arm/boot/zImage ~/android/racermod/cm7/recovery/gen1zImage
echo "Done!"

cd ~/android/racermod/cm7/recovery

echo "Creating gen1_recovery.img..."
../../mkbootimg --base 0x02A00000 --cmdline 'androidboot.hardware=mooncake console=null' --kernel gen1zImage --ramdisk ramdisk.gz -o temp/recovery/gen1_recovery.img
echo "Done!"



# Mod Version
export MODVER="1.5"

# Create new update.zip
echo "Packing CWM-5.0.2.8-$MODVER.zip..."
rm CWM-5.0.2.8-$MODVER.zip
cd temp
zip -r9 ../CWM-5.0.2.8-$MODVER.zip .
cd ..
rm -r temp
echo "Done!"

# Sign the update.zip
echo "Signing the update zip..."
cd ~/android/racermod/signapk
java -Xmx1024m -jar signapk.jar -w testkey.x509.pem testkey.pk8 ../cm7/recovery/CWM-5.0.2.8-$MODVER.zip ../cm7/recovery/CWM-5.0.2.8-$MODVER-signed.zip
cd ~/android/racermod/cm7/recovery
rm CWM-5.0.2.8-$MODVER.zip
mv CWM-5.0.2.8-$MODVER-signed.zip CWM-5.0.2.8-$MODVER.zip
echo "Done!"
