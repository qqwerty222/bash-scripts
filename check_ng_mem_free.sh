#! /bin/bash
# this script uses nsca-ng-client plugin - https://nsca-ng.org/

server_ip="10.0.2.15"
server_port="5667"
check_name="_Custom Memory usage status"

#localhost
host_name="10.0.2.8-passive-ng"

# parse vmstat output with | -aM active/inactive memory in Megabytes
mem_free=$(vmstat -aS M | sed -n '3 p' | sed 's/ [^0-9]*/|/g' | cut -d"|" -f5)
mem_inact=$(vmstat -aS M | sed -n '3 p' | sed 's/ [^0-9]*/|/g' | cut -d"|" -f6)
mem_active=$(vmstat -aS M | sed -n '3 p' | sed 's/ [^0-9]*/|/g' | cut -d"|" -f7)

mem_common=$(($mem_free + $mem_inact + $mem_active))
mem_used=$(($mem_inact + $mem_active))

# 25% / 50% / 75% of memory equal to:
mem_common_25=$(($mem_common / 4))
mem_common_50=$(($mem_common / 2))
mem_common_75=$(($mem_common_25 + $mem_common_50))

# compare used memory to free memory and send metrics
if (($mem_used < $mem_common_50)); then
        echo -e "10.0.2.8-passive-ng\t$check_name\t0\tMemory usage status is less than 50%" | send_nsca -H $server_ip -p $server_port
        exit 0
    elif (($mem_common_50 <= $mem_used && $mem_used <= $mem_common_75)); then
        echo -e "10.0.2.8-passive-ng\t$check_name\t1\tMemory usage is more than 50%" | send_nsca -H $server_ip -p $server_port
        exit 1
    elif (($mem_used >= $mem_common_75)); then
        echo -e "10.0.2.8-passive-ng\t$check_name\t2\tMemory usage status is more than 75%" | send_nsca -H $server_ip -p $server_port
        exit 2
    else
        echo -e "10.0.2.8-passive-ng\t$check_name\t3\tMemory usage status can't be found" | send_nsca -H $server_ip -p $server_port
        exit 3
fi