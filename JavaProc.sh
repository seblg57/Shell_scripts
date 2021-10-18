#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1
tcpid=$(ps -ef | grep threatconnect.jar | grep -v grep | awk '{print $2}')
jdkpath=$(grep -i JAVA_HOME /home/threatconnect/.bashrc | cut -d= -f2-)
tcjob=$(cat /etc/passwd | grep tc-job | cut -d: -f 1)

if [ -n $tcpid ]
then
	prlimit --pid $tcpid
	echo "***************************"
	$jdkpath/bin/jstack $tcpid > jstack.out
	ps -eLo pid,lwp,pcpu,vsz,comm | grep $tcpid | sort -nr | tail -n 10
	echo "***************************"
	ps -e -T | grep java | grep $tcpid | grep -v "00:00:00" | awk -F" " '{print $1,$2,$4}'| sort -r -k 3  > ps.out
	
	topjproc=$(cat ps.out | awk -F" " '{print $2}' | head -20)
	echo $topjproc
	for i in $topjproc
		do
		thread=$(printf '%x\n' $i)
		grep "nid=0x$(thread)" jstack.out
		cat ps.out | grep $i| awk -F" " '{print $3}'
		echo "***************************"
		rm -rf ps.out jstack.out
	done
else
	printf "\nAborting\n"
fi


