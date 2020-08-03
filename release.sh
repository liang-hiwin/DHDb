#!/bin/bash

# Current Version: 1.0.0

## How to get and use?
# git clone "https://github.com/hezhijie0327/DHDb.git" && chmod 0777 ./DHDb/release.sh && bash ./DHDb/release.sh

## Function
# Get Data
function GetData() {
    rm -rf ./Temp && mkdir ./Temp && cd ./Temp
    curl -s --connect-timeout 15 "https://raw.githubusercontent.com/hezhijie0327/AdFilter/master/adfilter_domains.txt" | grep -v "\#" > ./dhdb_data.tmp
    curl -s --connect-timeout 15 "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/master/gfwlist2agh_web.txt" | grep "\[\/" | sed "s/\[\///g;s/\/\].*//g" >> ./dhdb_data.tmp
}
# Analyse Data
function AnalyseData() {
    if [ ! -f "../dhdb_dead.txt" ]; then
        dhdb_data=($(cat ./dhdb_data.tmp | sort | uniq | head -n 1000 | awk "{ print $2 }"))
    else
        if [ ! -f "../dhdb_alive.txt" ]; then
            dhdb_data=($(cat ../dhdb_dead.txt > ./dhdb_data.old && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_data.old ./dhdb_data.tmp | sort | uniq | head -n 5000 | awk "{ print $2 }"))
        else
            dhdb_data=($(cat ../dhdb_alive.txt ../dhdb_dead.txt > ./dhdb_data.old && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_data.old ./dhdb_data.tmp | sort | uniq | head -n 5000 | awk "{ print $2 }"))
            if [ "${#dhdb_data[@]}" == 0 ]; then
                dhdb_data=($(get_total_line=$(sed -n '$=' ../dhdb_alive.txt) && for (( tmp = 0; tmp < 2000; tmp++ )); do generate_radom_line=$(( RANDOM%${get_total_line} )); generate_radom_line=$[generate_radom_line + 1]; sed -n "$generate_radom_line"p ../dhdb_alive.txt; done > ./dhdb_alive.old && get_total_line=$(sed -n '$=' ../dhdb_dead.txt) && for (( tmp = 0; tmp < 500; tmp++ )); do generate_radom_line=$(( RANDOM%${get_total_line} )); generate_radom_line=$[generate_radom_line + 1]; sed -n "$generate_radom_line"p ../dhdb_dead.txt; done > ./dhdb_dead.old && cat ./dhdb_alive.old ./dhdb_dead.old | sort | uniq | awk "{ print $2 }"))
            fi
        fi
    fi
}
# Output Data
function OutputData() {
    for dhdb_data_task in "${!dhdb_data[@]}"; do
        if [ "$(dig @dns.google ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
            echo "${dhdb_data[$dhdb_data_task]} (Status: alive)"
            echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp
        else
            if [ "$(dig @dns.opendns.com ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                echo "${dhdb_data[$dhdb_data_task]} (Status: alive)"
                echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp
            else
                if [ "$(dig @dns.quad9.net ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                    echo "${dhdb_data[$dhdb_data_task]} (Status: alive)"
                    echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp
                else
                    if [ "$(dig @one.one.one.one ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                        echo "${dhdb_data[$dhdb_data_task]} (Status: alive)"
                        echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp
                    else
                        echo "${dhdb_data[$dhdb_data_task]} (Status: dead)"
                        echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_dead.tmp
                    fi
                fi
            fi
        fi
    done
    if [ ! -f "../dhdb_dead.txt" ]; then
        cat ./dhdb_alive.tmp | sort | uniq > ./dhdb_alive.txt && mv ./dhdb_alive.txt ../dhdb_alive.txt
        cat ./dhdb_dead.tmp | sort | uniq > ./dhdb_dead.txt && mv ./dhdb_dead.txt ../dhdb_dead.txt
        cd .. && rm -rf ./Temp
        exit 0
    else
        cat ./dhdb_alive.tmp ../dhdb_alive.txt | sort | uniq > ./dhdb_alive.txt && mv ./dhdb_alive.txt ../dhdb_alive.txt
        cat ./dhdb_dead.tmp ../dhdb_dead.txt | sort | uniq > ./dhdb_dead.txt && mv ./dhdb_dead.txt ../dhdb_dead.txt
        cd .. && rm -rf ./Temp
        exit 0
    fi
}

## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
