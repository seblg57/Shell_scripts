#/bin/bash

LSCPU=$(which lscpu)
LSCPU=$?
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d,)
TOPCPU=$(top b -n1 | head -17 | tail -5)
TOPAPP=$(ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10)

if [ $LSCPU != 0 ]
then
RESULT=$RESULT" lscpu required "
else
cpus=$(lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}')
i=0
while [ $i -lt $cpus ]
do
echo "**********************************************************************************"
tput cup 8 25 ; echo -n  " CPU CURRENT LOAD "
echo "----------------------------------------------------------------------------------"
echo "CPU$i : `mpstat -P ALL | awk -v var=$i '{ if ($3 == var ) print $4 }' `"
let i=$i+1
done
fi

echo "**********************************************************************************"
tput cup 9 25 ; echo -n  " CPU AVERAGE LOAD "
echo "----------------------------------------------------------------------------------"
tput cup 10 25 ; echo -n  "$LOAD"
echo "**********************************************************************************"
echo " CPU AVERAGE LOAD "
echo "----------------------------------------------------------------------------------"
echo "$TOPCPU"
echo "**********************************************************************************"
echo " TOP PROCESS "
echo "----------------------------------------------------------------------------------"
echo "$TOPAPP"
echo "**********************************************************************************"
