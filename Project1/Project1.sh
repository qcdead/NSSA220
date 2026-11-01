#!/bin/bash

APP_NAMES=()
APP_PIDS=()

# run on script death
cleanup() {
    for pid in "${APP_PIDS[@]}"; do
        kill "$pid" 2>/dev/null
    done
}

start_apms() {
    local ip="192.168.206.135"
    for i in {1..6};
    do 
        local app_name="APM$i"
        "./project1_executables/$app_name" "$ip" &
        APP_PIDS+=($!)
        APP_NAMES+=("$app_name")
    done

    # printf '%s\n' "${APP_PIDS[@]}"
}

reset_vars() {
        CPU="none"
        MEM="none"
        NETWORK="none"
        NET_RX="none"
        NET_TX="none"
        DISK_WRITES="none"
        DISK_CAPACITY="none"
}

create_csv_log() {
    if [[ $1 ]];
    then 
        # if an app name is given as an argument
        local current_app_name=$1
        echo "time_since_start,cpu_usage,memory_usage" > "${current_app_name}_metrics.csv"
    else
        # if no pid is given, we're creating the system one
        echo "time_since_start,net_rx,net_tx,disk_writes,disk_capacity" > "system_metrics.csv"
    fi
}

app_data_collector() {
    local current_pid=$1
    # vars will get filled using ps for this specific pid
    local output 
    output=($(ps -p "$current_pid" -o %cpu,%mem | tail -n +2))
    CPU=${output[0]}
    MEM=${output[1]}
}

sys_data_collector() {
    # collect system data!
}

main() {
    # start APM 1 - 6
    start_apms
    # Sets to run cleanup on script exit
    trap cleanup EXIT
    # create system csv log
    create_csv_log
    # create executable csv logs
    for app_name in "${APP_NAMES[@]}";
        do
            create_csv_log "$app_name"
        done
	while true;
        do
            for ((i=0; i<${#APP_PIDS[@]}; i++))
                do
                    local current_app_pid="${APP_PIDS[i]}"
                    local current_app_name="${APP_NAMES[i]}"
                    reset_vars
                    # set var values using current  pid
                    app_data_collector "$current_app_pid"
                    # set system var values
                    sys_data_collector

                    # check to make sure the process is still running, probably a better way to do this
                    if [[ $CPU != "none" && -n "$CPU" ]];
                    then
                    # append neew line to csv, need to make sure it won't throw in a newline char at the end
                    echo "$SECONDS,$CPU,$MEM" >> "${current_app_name}_metrics.csv"
                    fi
                done
                # update system log
                echo "$SECONDS,$NET_RX,$NET_TX,$DISK_WRITES,$DISK_CAPACITY" >> "system_metrics.csv"
        sleep 5
        done
}
main
