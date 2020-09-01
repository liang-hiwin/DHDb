#!/bin/bash

# Current Version: 1.1.9

## How to get and use?
# git clone "https://github.com/hezhijie0327/DHDb.git" && chmod 0777 ./DHDb/release.sh && bash ./DHDb/release.sh

## Function
# Get Data
function GetData() {
    dhdb_checklist=(
        "https://raw.githubusercontent.com/hezhijie0327/AdFilter/master/adfilter_domains.txt"
        "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/master/gfwlist2agh_combine.txt"
        "https://raw.githubusercontent.com/hezhijie0327/Trackerslist/master/trackerslist_combine.txt"
    )
    rm -rf ./Temp && mkdir ./Temp && cd ./Temp
    for dhdb_checklist_task in "${!dhdb_checklist[@]}"; do
        curl -s --connect-timeout 15 "${dhdb_checklist[$dhdb_checklist_task]}" >> ./dhdb_checklist.tmp
    done
}
# Analyse Data
function AnalyseData() {
    if [ ! -f "../dhdb_dead.txt" ]; then
        dhdb_data=($(cat ./dhdb_checklist.tmp | sed "s/http\:\/\///g;s/https\:\/\///g;s/udp\:\/\///g;s/ws\:\/\///g;s/wss\:\/\///g;s/\:.*//g" | tr "/" "\n" | grep -E "^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-_\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$" | sort | uniq | head -n 500 | awk "{ print $2 }"))
    else
        if [ ! -f "../dhdb_alive.txt" ]; then
            dhdb_data=($(cat ./dhdb_checklist.tmp | sed "s/http\:\/\///g;s/https\:\/\///g;s/udp\:\/\///g;s/ws\:\/\///g;s/wss\:\/\///g;s/\:.*//g" | tr "/" "\n" | grep -E "^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-_\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$" > dhdb_data.tmp && cat ../dhdb_dead.txt > ./dhdb_data.old && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_data.old ./dhdb_data.tmp | sort | uniq | head -n 3000 | awk "{ print $2 }"))
        else
            dhdb_data=($(cat ./dhdb_checklist.tmp | sed "s/http\:\/\///g;s/https\:\/\///g;s/udp\:\/\///g;s/ws\:\/\///g;s/wss\:\/\///g;s/\:.*//g" | tr "/" "\n" | grep -E "^(([a-z]{1})|([a-z]{1}[a-z]{1})|([a-z]{1}[0-9]{1})|([0-9]{1}[a-z]{1})|([a-z0-9][-_\.a-z0-9]{1,61}[a-z0-9]))\.([a-z]{2,13}|[a-z0-9-]{2,30}\.[a-z]{2,3})$" > dhdb_data.tmp && cat ../dhdb_alive.txt ../dhdb_dead.txt > ./dhdb_data.old && awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_data.old ./dhdb_data.tmp | sort | uniq | head -n 3000 | awk "{ print $2 }"))
            if (( ${#dhdb_data[@]} <= 5 )); then
                dhdb_data=($(get_total_line=$(sed -n '$=' ../dhdb_alive.txt) && for (( tmp = 0; tmp < 2400; tmp++ )); do generate_random_line=$(( RANDOM%${get_total_line} )); generate_random_line=$[generate_random_line + 1]; sed -n "$generate_random_line"p ../dhdb_alive.txt; done > ./dhdb_alive.old && get_total_line=$(sed -n '$=' ../dhdb_dead.txt) && for (( tmp = 0; tmp < 600; tmp++ )); do generate_random_line=$(( RANDOM%${get_total_line} )); generate_random_line=$[generate_random_line + 1]; sed -n "$generate_random_line"p ../dhdb_dead.txt; done > ./dhdb_dead.old && cat ./dhdb_alive.old ./dhdb_dead.old | sort | uniq | awk "{ print $2 }"))
            fi
        fi
    fi
}
# Output Data
function OutputData() {
    result_alive="0" && result_dead="0" && time_strated=$(date +%s) && time_limited="3000"
    for dhdb_data_task in "${!dhdb_data[@]}"; do
        if (( $(($(date +%s) - ${time_strated})) <= ${time_limited} )); then
            if [ "$(dig A @dns.google ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ] || [ "$(dig AAAA @dns.google ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                echo "${dhdb_data[$dhdb_data_task]} (Status: alive | Index: $((${dhdb_data_task} + 1)))"
                echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp && result_alive=$((${result_alive} + 1))
            else
                if [ "$(dig A @dns.opendns.com ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ] || [ "$(dig AAAA @dns.opendns.com ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                    echo "${dhdb_data[$dhdb_data_task]} (Status: alive | Index: $((${dhdb_data_task} + 1)))"
                    echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp && result_alive=$((${result_alive} + 1))
                else
                    if [ "$(dig A @one.one.one.one ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ] || [ "$(dig AAAA @one.one.one.one ${dhdb_data[$dhdb_data_task]} | grep 'NXDOMAIN\|SERVFAIL\|SOA')" == "" ]; then
                        echo "${dhdb_data[$dhdb_data_task]} (Status: alive | Index: $((${dhdb_data_task} + 1)))"
                        echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_alive.tmp && result_alive=$((${result_alive} + 1))
                    else
                        echo "${dhdb_data[$dhdb_data_task]} (Status: dead | Index: $((${dhdb_data_task} + 1)))"
                        echo "${dhdb_data[$dhdb_data_task]}" >> ./dhdb_dead.tmp && result_dead=$((${result_dead} + 1))
                    fi
                fi
            fi
        fi
    done
    echo "(Alive: ${result_alive} | Dead: ${result_dead} | Total: $(((${result_alive} + ${result_dead}))))"
    if [ ! -f "../dhdb_dead.txt" ]; then
        cat ./dhdb_alive.tmp | sort | uniq > ./dhdb_alive.txt
        cat ./dhdb_dead.tmp | sort | uniq > ./dhdb_dead.txt
        awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_alive.txt ./dhdb_dead.txt | sort | uniq > ../dhdb_dead.txt
        awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_dead.txt ./dhdb_alive.txt | sort | uniq > ../dhdb_alive.txt
        cd .. && rm -rf ./Temp
        exit 0
    else
        cat ./dhdb_alive.tmp ../dhdb_alive.txt | sort | uniq > ./dhdb_alive.txt
        cat ./dhdb_dead.tmp ../dhdb_dead.txt | sort | uniq > ./dhdb_dead.txt
        awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_alive.txt ./dhdb_dead.txt | sort | uniq > ../dhdb_dead.txt
        awk 'NR == FNR { tmp[$0] = 1 } NR > FNR { if ( tmp[$0] != 1 ) print }' ./dhdb_dead.txt ./dhdb_alive.txt | sort | uniq > ../dhdb_alive.txt
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
