#!/bin/bash

EXECUTABLES_PIDS=()

SECONDS=()

PROCCESS_OUTPUT=()

cleanup() {
    for pid in "${EXECUTABLES_PIDS[@]}"; do
        kill "$pid" 2>/dev/null
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

process_data (pid) {
    PROCCESS_OUTPUT+= "$SECONDS"
    process_data= (ps -p "$pid" -o %cpu, %mem | tail -n +2)
    PROCCESS_OUTPUT=+ "$process_data"
}


run_loop (){
    SECONDS+= 5
    for pid in "${EXECUTABLES_PIDS[@]}" do
        #somethng
    done
    #add systems cvs writer here
}

