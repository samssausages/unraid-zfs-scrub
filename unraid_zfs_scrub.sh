#!/bin/bash

# Run a scrub on all ZFS pools in parallel
# Get a list of all ZFS pools
pools=$(zpool list -H -o name)

# Loop through each pool and run a scrub in the background
for pool in $pools; do
    echo "Scrubbing pool $pool..."
    zpool scrub "$pool" &
done

# Wait for all scrubs to complete
while true; do
    in_progress=0
    for pool in $pools; do
        if zpool status "$pool" | grep -q "scan: scrub in progress"; then
            in_progress=1
            break
        fi
    done
    if [ $in_progress -eq 0 ]; then
        break
    fi
    sleep 10
done

# Check the status of each scrub
for pool in $pools; do
    if zpool status "$pool" | grep -q "errors: No known data errors"; then
        echo "Scrub of pool $pool completed successfully."
    else
        echo "Scrub of pool $pool failed with errors."
    fi
done

## Run on only one pool at a time
# Get a list of all ZFS pools
# pools=$(zpool list -H -o name)

# # Loop through each pool and run a scrub
# for pool in $pools; do
#     echo "Scrubbing pool $pool..."
#     zpool scrub "$pool"
#     if [ $? -eq 0 ]; then
#         echo "Scrub of pool $pool completed successfully."
#     else
#         echo "Scrub of pool $pool failed with errors."
#     fi
# done


