#!/sbin/sh
#
# Simple device checkup file for Quanta compatible devices.
#

DEVICE=`find fstab.* | head -n 1 | cut -d . -f2`

if [ "$DEVICE" = "mako" -o "$DEVICE" = "flo" ] ; then
    echo "Device compatible: $DEVICE"
    exit 0
else
    echo "Device not compatible"
    exit 1
fi
