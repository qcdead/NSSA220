#!/bin/bash

# key:value
# apm_name:apm_pid 
declare -A APM_DICT

# run on script death
cleanup() {
    # loops through vals
    for pid in "${APM_DICT[@]}"; do
        kill "$pid" 2>/dev/null
    done
}

start_apms() {
    local ip="192.168.206.135"
    for i in {1..6};
    do 
        local apm_name="APM$i"
        "./project1_executables/$apm_name" "$ip" &
        APM_DICT["$apm_name"]=$!
        # ^ add to dict, apm_name:apm_pid where $! is pid 
    done

    # printf '%s\n' "${APM_PIDS[@]}"
}

reset_vars() {
        CPU="none"
        MEM="none"
        NET_RX="none"
        NET_TX="none"
        DISK_WRITES="none"
        DISK_CAPACITY="none"
}

create_csv_log() {
    if [[ $1 ]];
    then 
        # if an apm name is given as an argument
        local current_apm_name=$1
        echo "time_since_start,cpu_usage,memory_usage" > "${current_apm_name}_metrics.csv"
    else
        # if no pid is given, we're creating the system one
        echo "time_since_start,net_rx,net_tx,disk_writes,disk_capacity" > "system_metrics.csv"
    fi
}

apm_data_collector() {
    local current_pid=$1
    # vars will get filled using ps for this specific pid
    local output 
    output=($(ps -p "$current_pid" -o %cpu,%mem 2>/dev/null | tail -n +2))
    CPU=${output[0]}
    MEM=${output[1]}
}

sys_data_collector() {
    # collect system data!
    # assign values to GLOBAL vars!!!!!
    local NET_OUTPUT

    NET_OUTPUT=$(ifstat ens192 | awk '$1 == "ens192" {print $7, $9}')
    read -r NET_RX NET_TX <<< "$NET_OUTPUT"

    # Disk writes in kB/s
    DISK_WRITES=$(iostat -d -k -y sda 1 1 | awk '
        /^Device/ {
            for (i = 1; i <= NF; i++)
                if ($i == "kB_wrtn/s") col = i
        }
        $1 == "sda" && col {print $col}
    ')

    # Available disk capacity in MB
    DISK_CAPACITY=$(df --block-size=M --output=avail / | tail -n +2 | tr -d ' M')
}

main() {
    # start APM 1 - 6
    start_apms
    
    # Sets to run cleanup on script exit
    trap cleanup EXIT
    
    # create system csv log
    create_csv_log

    # create executable csv logs, bang loops through keys instead of vals
    for apm_name in "${!APM_DICT[@]}";
        do
            create_csv_log "$apm_name"
        done
	while true;
        do
            # bang loops through keys instead of vals
            for apm_name in "${!APM_DICT[@]}";
                do
                    local current_apm_pid="${APM_DICT[$apm_name]}"
                    local current_apm_name="$apm_name"

                    reset_vars
                    # set var values using current pid
                    apm_data_collector "$current_apm_pid"

                    # check to make sure the process is still running, probably a better way to do this
                    if [[ $CPU != "none" && -n "$CPU" ]];
                    then
                    # append new line to csv, need to make sure it won't throw in a newline char at the end
                    echo "$SECONDS,$CPU,$MEM" >> "${current_apm_name}_metrics.csv"
                    #       ^ seconds is a built in var that tracks from start of script time
                    fi
                done

                reset_vars
                # set system var values
                sys_data_collector
                # update system log
                echo "$SECONDS,$NET_RX,$NET_TX,$DISK_WRITES,$DISK_CAPACITY" >> "system_metrics.csv"
        sleep 5
        done
}
main
