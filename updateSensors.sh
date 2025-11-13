#!/bin/sh

# Sets the scripts path and starts script(s).
# Can be directly called from the UI scheduler.
# NOTE: this is defined for an interval of 3 minutes.

## Change into script directory
cd "$(dirname "$(readlink -f "$0")")" || exit 1

## Fetch timestamp
start=$(date +%s)

## source common
. ./common.sh

## Loop 6 times
for i in 0 1 2 3 4 5; do
    ## Each 30 seconds:
    printf 'Iteration %s started at %s\n' "$i" "$(date +%T)"

    ## After 0 and 90 seconds:
    if [ "$i" -eq 0 ] || [ "$i" -eq 3 ]; then
        sh ./checkCPU.sh
    fi

    ## Each 30 seconds:
    fetch_entities
    sh ./checkAccessRestriction.sh &
    sh ./checkAdBlock.sh &

    ## Once after 0 seconds:
    if [ "$i" -eq 0 ]; then
        sh ./checkLeases.sh &
    fi

    ## Once after 30 seconds:
    if [ "$i" -eq 1 ]; then
        sh ./checkMem.sh &
        sh ./checkDisk.sh &
    fi

    ## Once after 60 seconds:
    if [ "$i" -eq 2 ]; then
        sh ./checkLoad.sh &
        sh ./checkPing.sh &
    fi

    ## Once after 90 seconds:
    if [ "$i" -eq 3 ]; then
        sh ./checkLeases.sh &
    fi

    ## Once after 120 seconds:
    if [ "$i" -eq 4 ]; then
        sh ./checkClients.sh &
        sh ./checkWireless.sh &
    fi

    ## Once after 150 seconds:
    if [ "$i" -eq 5 ]; then
        sh ./checkConnections.sh &
        sh ./checkBandwidthInterface.sh &
        break
    fi

    ## Wait for scripts to finish
    wait

    now=$(date +%s)
    next=$(( start + (i + 1) * 30 ))
    sleep_seconds=$(( next - now ))
    if [ "$sleep_seconds" -gt 0 ]; then
        printf 'Sleeping for %s seconds\n' "$sleep_seconds"
        sleep "$sleep_seconds"
    fi

#    echo "i=${i} start=${start} next=${next} now=${now} sleep_seconds=${sleep_seconds}"
done

## Wait again after leaving the loop
wait

## Change into initial directory
cd - >/dev/null 2>&1 || exit 1
exit 0
