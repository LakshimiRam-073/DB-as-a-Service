#!/bin/bash


start=5000
end=8000

is_port_in_use() {
    local port=$1
    if ss -lnt | awk '{print $4}' | grep -q ":$port\$"; then
        return 0
    else
        return 1
    fi
}

# Find and return the first free port in the range
find_free_port() {
    local start_port=$1
    local end_port=$2

    for (( port=start_port; port<=end_port; port++ )); do
        if ! is_port_in_use $port; then
            echo $port
            return 0
        fi
    done

}

free_port=$(find_free_port $start $end)


echo "$free_port"
