#! /bin/bash

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

# compare used memory to free memory
if (($mem_used < $mem_common_50)); then
        echo "Ok - memory usage less than 50%"
        exit 0
    elif (($mem_common_50 <= $mem_used && $mem_used <= $mem_common_75)); then
        echo "WARNING - memory usage is more than 50% but less then 75%"
        exit 1
    elif (($mem_used >= $mem_common_75)); then
        echo "CRITICAL - memory usage is more than 75%"
        exit 2
    else
        echo "UNKNOWN - memory usage can't be found"
        exit 3
fi
