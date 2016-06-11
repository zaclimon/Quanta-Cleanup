#!/sbin/sh
#
# Executes the appropriate cleanup script based on Android version
#

# Check if /system is mounted
mount | grep -qs /system

# Try to mount /system if it isn't the case.
if [ ! $? -eq 0 ] ; then
    mount -o ro /system;
    if [ $? -gt 0 ] ; then
        echo "/system can't be mounted, exiting..."
        exit 1
    fi
fi

# Do our stuff is /system is mounted.
if [ $? -eq 0 ] ; then
    ANDROID_API=`cat /system/build.prop | grep ro.build.version.sdk | cut -d = -f2`
    echo "Executing clean_api_$ANDROID_API.sh"
    . tmp/clean_api_$ANDROID_API.sh
    exit $?
else
    echo "/system not mounted, exiting."
    exit 1
fi
