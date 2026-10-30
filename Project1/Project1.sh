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

eset_vars() {
        CPU="none"
        MEM="none"
        NETWORK="none"
        DISK="none"
        NET_RX="none"
        NET_TX="none"
        TEST="none"
}

app_data_collector() {
        local current_pid=$1
        # vars will get filled using ps for this specific pid
        CPU="0%"
        MEM="0%"
}

main() {
        for pid in $APP_PIDS;
        do
            create_csv(pid)
        done
	while true;
        do
            for pid in $APP_PIDS
                do
                    reset_vars
                        # set var values using current  pid
                        app_data_collector($pid)
                        # set system var values
                        sys_data_collector

                        # check to make sure the pid exists, probably a better way to do this
                        if $CPU != "none";
                        then
                        # append neew line to csv, need to make sure it won't throw in a newline char at the end
                        echo "$SECONDS,$CPU,$MEM" >> "$pid.csv"
                        fi
                done
                # update system log
                echo "$SECONDS,$DISK,$NET_RX" >> "system.csv"
        sleep 5
        done
}
main()
