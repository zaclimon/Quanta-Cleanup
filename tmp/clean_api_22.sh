#!/sbin/sh
#
# Init scripts cleaner for Quanta Kernel
# Cleans up init scripts to ensure a stock experience
# Isaac Pateau (zaclimon)
#
# Version 1.0 (API 22)
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
    sed '/scaling_governor "conservative"/ s/conservative/ondemand/g' -i $DEVICE_INIT_FILE

    if [ "$DEVICE" = "flo" ] ; then
        sed '/cpu3\/cpufreq\/scaling_governor "ondemand"/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/down_differential 10' -i $DEVICE_INIT_FILE
        sed '/ondemand\/down_differential 10/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core 60' -i $DEVICE_INIT_FILE
        sed '/ondemand\/up_threshold_multi_core 60/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core 3' -i $DEVICE_INIT_FILE
        sed '/ondemand\/down_differential_multi_core 3/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq 918000' -i $DEVICE_INIT_FILE
        sed '/ondemand\/optimal_freq 918000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sync_freq 1026000' -i $DEVICE_INIT_FILE
        sed '/ondemand\/sync_freq 1026000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load 80' -i $DEVICE_INIT_FILE
    fi

    sed '/cpu3\/cpufreq\/scaling_governor "ondemand"/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 90' -i $DEVICE_INIT_FILE
    sed '/cpu3\/cpufreq\/scaling_governor "powersave"/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 90' -i $DEVICE_INIT_FILE
    sed '/ondemand\/up_threshold 90/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate 50000' -i $DEVICE_INIT_FILE
    sed '/ondemand\/sampling_rate 50000/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy 1' -i $DEVICE_INIT_FILE
    sed '/ondemand\/io_is_busy 1/ a\    write /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor 4' -i $DEVICE_INIT_FILE

    # Remove all custom tweaks
    sed '/mmcblk0\/queue/d' -i $DEVICE_INIT_FILE
    sed '/sys.boot.completed=1/,/high_load_counter/d' -i $DEVICE_INIT_FILE
    sed '/online 1/d' -i $DEVICE_INIT_FILE

    # Restore cpu_on_migrate and cpu cores activation (For Flo/Deb)
    if [ "$DEVICE" = "flo" ] ; then
        sed '/cpu.notify_on_migrate/ s/0/1/g' -i $DEVICE_INIT_FILE
        sed '/cpu.notify_on_migrate/ i\    write /sys/devices/system/cpu/cpu1/online 1' -i $DEVICE_INIT_FILE
        sed '/cpu1\/online 1/ a\    write /sys/devices/system/cpu/cpu2/online 1' -i $DEVICE_INIT_FILE
        sed '/cpu2\/online 1/ a\    write /sys/devices/system/cpu/cpu3/online 1' -i $DEVICE_INIT_FILE
    fi

    # Remove the "disabled" option on thermald and mdprecision
    sed '/group radio system/{n;d}' -i $DEVICE_INIT_FILE
    sed '/group root system/{n;d}' -i $DEVICE_INIT_FILE

    # Remove modifications on init.rc
    sed '/chown system system \/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_min_freq/d' -i $INIT_FILE
    sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_min_freq/d' -i $INIT_FILE
    sed '/chown system system \/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_governor/d' -i $INIT_FILE

    echo "Init files restored"
else
    echo "No performance profiles found. Scripts might have been cleaned up."
fi

exit 0
