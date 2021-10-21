#/bin/bash

LSCPU=$(which lscpu)
LSCPU=$?
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d,)
TOPCPU=$(top b -n1 | head -17 | tail -5)
TOPAPP=$(ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10)

function print_centered {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" "$1" "$filler"
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}

if [ $LSCPU != 0 ]
then
RESULT=$RESULT" lscpu required "
else
cpus=$(lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}')
i=0
while [ $i -lt $cpus ]
do
echo "**********************************************************************************"
echo " CPU CURRENT LOAD "
echo "----------------------------------------------------------------------------------"
echo "CPU$i : `mpstat -P ALL | awk -v var=$i '{ if ($3 == var ) print $4 }' `"
let i=$i+1
done
fi
echo "**********************************************************************************"
echo " CPU AVERAGE LOAD "
echo "----------------------------------------------------------------------------------"
echo "$LOAD"
echo "**********************************************************************************"
echo " CPU AVERAGE LOAD "
echo "----------------------------------------------------------------------------------"
echo "$TOPCPU"
echo "**********************************************************************************"
echo " TOP PROCESS "
echo "----------------------------------------------------------------------------------"
echo "TOPAPP"
echo "**********************************************************************************"
