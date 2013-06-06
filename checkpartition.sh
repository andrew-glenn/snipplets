#!/bin/bash
disk_mount="/foo/bar"

#Thresholds, in *USAGE*, not *FREE*
crit_threshold="80"
warn_threshold="75"

_check_attempt=1
# Check the mount
while true; do
    if [ $(mount | egrep '$disk_mount ' -c ) -eq 1 ]; then
        _mounted=yes
        touch $diskmount/.fs_monitoring_test
            if [ $? -eq 0 ]; then
                _writeable=yes
            fi
    fi

    # If the filesystem is mounted and writeable, check usage.
    if [ $_mounted == "yes" ] && [ $_writeable == "yes" ]; then
        _use=$(df $disk_mount | sed -e 1d -e 's/%//g' | awk '{print $5}')

        # If the usage is between the warning and critical thresholds.
        if [ $_use -ge $warn_threshold -a $_use -lt $crit_threshold ]; then
            logger -p local0.crit "Warning: $disk_mount is above threshold, current value is $_use. Threshold is $warn_threshold"
            exit 0

        # If the usage is above the critical thresolds.
        elif [ $_use -ge $crit_threshold ]; then
            logger -p local0.crit "Critical: $disk_mount is above threshold, current value is $_use. Threshold is $crit_threshold"
            exit 0

        fi

    else
    # If the mount isn't mounted or writable.
        # If we've gone over this for three times.
        if [ $_check_attempt -eq 3 ];
            logger -p local0.crit "$disk_mount is unaccessable. Please investigate!"
            exit 0

        else
            # Increment the variable, sleep 5 seconds, hit the true loop again.
            let _check_attempt++
            sleep 5
        fi
    fi
done
