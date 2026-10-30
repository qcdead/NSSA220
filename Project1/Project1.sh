#!/bin/bash

EXECUTABLES_PIDS=()

stop_executables() {
    for pid in "${APP_PIDS[@]}"; do
        kill "$pid"
    done
}
# Sets to run cleanup on script exit
trap cleanup EXIT

start_executables() {
    # Change me to a loop later also unhardcode ip
    "./project1_executables/APM1" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)
    "./project1_executables/APM2" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)   
    "./project1_executables/APM3" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)
    "./project1_executables/APM4" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)
    "./project1_executables/APM5" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)
    "./project1_executables/APM6" "192.168.206.135" &
    EXECUTABLES_PIDS+=($!)

    printf '%s\n' "${EXECUTABLES_PIDS[@]}"
}

start_executables