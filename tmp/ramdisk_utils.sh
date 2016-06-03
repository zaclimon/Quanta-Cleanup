#!/sbin/sh
#
# Simple utility script to unpack/repack + flash kernels on-the-go
# Thanks to osm0sis@XDA for the binaries.
#

COMMAND=$1

FSTAB=`find fstab.* | head -n 1`
BOOT_PARTITION=`grep /boot $FSTAB | cut -d " " -f1`

cd /tmp

if [ "$COMMAND" = "unpack" ] ; then

    dd if=$BOOT_PARTITION of=boot.img
    ./unpackbootimg -i boot.img

    # Continue with the unpacking...
    mkdir ramdisk
    cd ramdisk
    gzip -dc ../boot.img-ramdisk.gz | cpio -i
    exit 0
elif [ "$COMMAND" = "repack" ] ; then

    # Define the kernel's attributes for the repacking.
    KERNEL_CMDLINE=`cat boot.img-cmdline | sed 's/.*/"&"/'`
    KERNEL_BASE=`cat boot.img-base`
    KERNEL_PAGESIZE=`cat boot.img-pagesize`
    KERNEL_OFFSET=`cat boot.img-kerneloff`
    RAMDISK_OFFSET=`cat boot.img-ramdiskoff`

    cd ramdisk

    # Repack the kernel. Looks like we have to put the mkbootimg command in a separate script because it doesn't look like it is possible to parse the cmdline into the "raw command".
    find . | cpio --create --format='newc' | gzip > ../ramdisk.gz
    cd ..
    echo "#!/sbin/sh" > /tmp/newboot.sh
    echo "./mkbootimg --kernel boot.img-zImage --ramdisk ramdisk.gz --cmdline $KERNEL_CMDLINE --base $KERNEL_BASE --pagesize $KERNEL_PAGESIZE --kernel_offset $KERNEL_OFFSET --ramdisk_offset $RAMDISK_OFFSET -o newboot.img" >> newboot.sh
    chmod 0755 newboot.sh
    . /tmp/newboot.sh

    # Flash the new kernel
    dd if=/tmp/newboot.img of=$BOOT_PARTITION
    exit 0
fi
