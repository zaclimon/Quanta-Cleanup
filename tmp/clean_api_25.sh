#!/sbin/sh
#
# Init scripts cleaner for Quanta Kernel
# Cleans up init scripts to ensure a stock experience
# Isaac Pateau (zaclimon)
#
# Version 1.0 (API 25)
#

# Define the attributes now
DEVICE=`find fstab.* | head -n 1 | cut -d . -f2`
DEVICE_INIT_FILE=init.$DEVICE.rc
INIT_FILE=init.rc

# Preparing
if [ -d /tmp/ramdisk ] ; then
    cd /tmp/ramdisk
else
    echo "Ramdisk directory not present"
    echo "Has the kernel been unpacked?"
    exit 1
fi

# Don't remove everything until we're sure that the kernel is modified.
if [ -f init.quanta.rc ] ; then

    # Remove Quanta's specific init script.
    rm -f init.quanta.rc
    sed '/init.quanta.rc/d' -i $DEVICE_INIT_FILE

    # Remove the "disabled" option on thermald and mdprecision
    sed '/group radio system/{n;d}' -i $DEVICE_INIT_FILE
    sed '/group root system/{n;d}' -i $DEVICE_INIT_FILE

    # Restore permissions for Interactive on init.rc
    sed '/sys\/devices\/system\/cpu\/cpufreq\/interactive/ s/0664/0660/g' -i $INIT_FILE

    echo "Init files restored"
else
    echo "No quanta specific init script found. Scripts might have been cleaned up."
fi

exit 0
