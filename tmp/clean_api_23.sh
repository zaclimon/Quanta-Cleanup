#!/sbin/sh
#
# Init scripts cleaner for Quanta Kernel
# Cleans up init scripts to ensure a stock experience
# Isaac Pateau (zaclimon)
#
# Version 1.0 (API 23)
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
if [ -f init.performance_profiles.rc ] ; then

    # Remove the custom performance profiles
    rm -f init.performance_profiles.rc
    sed '/init.performance_profiles.rc/d' -i $DEVICE_INIT_FILE

    # Restore Ondemand values
    sed '/scaling_governor "interactive"/ s/interactive/ondemand/g' -i $DEVICE_INIT_FILE
    sed '/cpu3\/cpufreq\/scaling_governor "ondemand"/ a\    restorecon_recursive /sys/devices/system/cpu/cpufreq/ondemand' -i $DEVICE_INIT_FILE

    if [ "$DEVICE" = "flo" ] ; then
        sed '/restorecon_recursive \/sys\/devices\/system\/cpu\/cpufreq\/ondemand/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/down_differential 10' -i $DEVICE_INIT_FILE
        sed '/ondemand\/down_differential 10/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core 60' -i $DEVICE_INIT_FILE
        sed '/ondemand\/up_threshold_multi_core 60/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core 3' -i $DEVICE_INIT_FILE
        sed '/ondemand\/down_differential_multi_core 3/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq 918000' -i $DEVICE_INIT_FILE
        sed '/ondemand\/optimal_freq 918000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sync_freq 1026000' -i $DEVICE_INIT_FILE
        sed '/ondemand\/sync_freq 1026000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load 80' -i $DEVICE_INIT_FILE
    fi

    sed '/restorecon_recursive \/sys\/devices\/system\/cpu\/cpufreq\/ondemand/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 90' -i $DEVICE_INIT_FILE
    sed '/cpu3\/cpufreq\/scaling_governor "powersave"/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 90' -i $DEVICE_INIT_FILE
    sed '/ondemand\/up_threshold 90/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate 50000' -i $DEVICE_INIT_FILE
    sed '/ondemand\/sampling_rate 50000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy 1' -i $DEVICE_INIT_FILE
    sed '/ondemand\/io_is_busy 1/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor 4' -i $DEVICE_INIT_FILE

    # Restore cpu_on_migrate (For Flo/Deb)
    if [ "$DEVICE" = "flo" ] ; then
        sed '/cpu3\/online 1/ a\    write /dev/cpuctl/apps/cpu.notify_on_migrate 1' -i $DEVICE_INIT_FILE
    fi

    # Remove all max frequency related stuff
    sed '/scaling_max_freq 1512000/ d' -i $DEVICE_INIT_FILE

    # Remove all custom tweaks
    if [ "$DEVICE" = "mako" ] ; then
        sed '/cpu1\/online 1/,/write \/sys\/kernel\/mm\/ksm\/run 1/{n;d}' -i $DEVICE_INIT_FILE
        sed '/cpu1\/online 1/,/write \/sys\/kernel\/mm\/ksm\/run 1/d' -i $DEVICE_INIT_FILE
    else
        sed '/# Interactive/,/write \/sys\/kernel\/mm\/ksm\/run 1/{n;d}' -i $DEVICE_INIT_FILE
        sed '/# Interactive/,/write \/sys\/kernel\/mm\/ksm\/run 1/d' -i $DEVICE_INIT_FILE
    fi

    # Remove the "disabled" option on thermald and mdprecision
    sed '/group radio system/{n;d}' -i $DEVICE_INIT_FILE
    sed '/group root system/{n;d}' -i $DEVICE_INIT_FILE

    # Restore permissions for Interactive on init.rc
    sed '/sys\/devices\/system\/cpu\/cpufreq\/interactive/ s/0664/0660/g' -i $INIT_FILE

    echo "Init files restored"
else
    echo "No performance profiles found. Scripts might have been cleaned up."
fi

exit 0
