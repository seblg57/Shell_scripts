#!/bin/bash
#############################################################################################
#|__   __| |  | |  __ \|  ____|   /\|__   __/ ____/ __ \| \ | | \ | |  ____/ ____|__   __|  #
#    | |  | |__| | |__) | |__     /  \  | | | |   | |  | |  \| |  \| | |__ | |       | |    #
#    | |  |  __  |  _  /|  __|   / /\ \ | | | |   | |  | | . ` | . ` |  __|| |       | |    #
#    | |  | |  | | | \ \| |____ / ____ \| | | |___| |__| | |\  | |\  | |___| |____   | |    #
#    |_|  |_|  |_|_|  \_\______/_/    \_\_|  \_____\____/|_| \_|_| \_|______\_____|  |_|    #
#                                                                                           #
#############################################################################################
##                                                                                                                                                                                  #
# THREATCONNECT                                                                                                                                         #
#"""""""""""""""""""""""""                                                                                                                                      #
# Created by:  Seb THEIS |      16/02/2020                                                                                                              #
#.........................                                                                                                                                      #
#                                                                                                                                                                                       #
#                       This Script assist engineers to deploy the Threatconnect                                                #
#                       1)      System Check                                                                                                                            #
#                                                                                                                                         #
#                                                                                                                                                                                       #
#                                                                                                                                                                                       #
#                                                                                                                                                                                       #
#############################################################################################

# Purpose: Display pause prompt
# $1-> Message (optional)
#function pause(){
#       local message="$@"
#       [ -z $message ] && message="Press [Enter] key to continue..."
#       read -p "$message" readEnterKey
#}
function pause(){
echo
echo
message="Press [Enter] key to continue... or CTRL+C to exit"
read -p "$message" readEnterKey
}
function show_menu(){
echo  -e ' \e[38;5;208m

 ████████╗██╗  ██╗██████╗ ███████╗ █████╗ ████████╗ ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
 ╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
    ██║   ███████║██████╔╝█████╗  ███████║   ██║   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║
    ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║   ██║   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║
    ██║   ██║  ██║██║  ██║███████╗██║  ██║   ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║
    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝ \e[0m'







                echo
                echo -e                               "\e[40;38;5;82m                                   1. System Check
                                        17. exit\e[0m"
}

function write_header(){
        local h="$@"
        echo "---------------------------------------------------------------"
        echo "     ${h}"
        echo "---------------------------------------------------------------"
}





function sys_info(){
#        write_header " System information "
#redis_version = $(redis-server --version | awk {'print $3'})
if [ -e /usr/local/bin/redis-server ]
then
        redisver=$(/usr/local/bin/redis-server --version | awk {'print $3'})
else
    redisver=$(echo "$(tput setaf 1) Redis is not running / Installed $(tput sgr0) ")
fi

if [ -e /etc/redis/6379.conf ]
then
    sample=$(cat /etc/redis/6379.conf | tail -n 1)
        allkeys=$(cat /etc/redis/6379.conf | tail -n -2 | head -n 1)
        mem=$(cat /etc/redis/6379.conf | tail -n -3 | head -n 1)

else
    sample=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
        allkeys=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
        mem=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
fi
if [ -e /etc/init.d/redis_6379 ]
then
    user=$(cat /etc/init.d/redis_6379 | grep USER=redis )
        com1=$(cat /etc/init.d/redis_6379 | awk 'NR==34')
        com2=$(cat /etc/init.d/redis_6379 | awk 'NR==35')

else
    user=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
        com1=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
        com2=$(echo "$(tput setaf 1) Install Redis First $(tput sgr0) ")
fi

thpredis=$(grep never /sys/kernel/mm/transparent_hugepage/enabled | awk '{print $3}' | sed -e "s/^.//" | sed -e "s/.$//")

if [ $thpredis == 'never' ]
then
    thpredisok=$(echo "$(tput setaf 2)THP Disabled  $(tput sgr0)")
else
        thpredisok=$(echo "$(tput setaf 1) THP Enabled $(tput sgr0)")
fi

overcored=$(grep overcommit /etc/sysctl.conf)

if [ -z "$overcored" ]
then
    overcoredok=$(echo "$(tput setaf 1) echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf $(tput sgr0)")
else
        overcoredok=$(echo "$(tput setaf 2)Memory Overcommit Set $(tput sgr0)")
fi

somaxconntc=$(sysctl --value net.core.somaxconn)

if [ $somaxconntc -le "512" ]
then
        somaxconntcok=$(echo "$(tput setaf 2) $somaxconntc $(tput sgr0)")
else
        somaxconntcok=$(echo "$(tput setaf 1) $somaxconntc $(tput sgr0)")
fi

if [ -e /usr/local/bin/pip3.6 ]
then
    tcex=$(/usr/local/bin/pip3.6 show tcex | awk 'NR==2')
else
        tcex=$(echo "$(tput setaf 1)TCEX Not Installed or Old Version $(tput sgr0)")
fi
if [ -e /usr/local/bin/python3.6 ]
then
    pyth=$(ls -ld /usr/local/bin/python3.6 | awk {'print $9'} | cut -f5 -d'/')
else
        pyth=$(echo "$(tput setaf 1)Python Not Installed or Old Version $(tput sgr0)")
fi

pamtc=$(grep threatconnect /etc/pam.d/su | awk '{print $7}')
pamtcjob=$(grep tc-job /etc/pam.d/su | awk '{print $7}')

if [ -z "$pamtc" ]
then
    pamtcok=$(echo "$(tput setaf 1)Threatconnect user NOT found in PAM $(tput sgr0)")
else
        pamtcok=$(echo "$(tput setaf 2)Threatconnect user found in PAM $(tput sgr0)")
fi

if [ $pamtcjob == 'tc-job' ]
then
    pamtcjobok=$(echo "$(tput setaf 2)tc-job user found in PAM $(tput sgr0)")
else
        pamtcjobok=$(echo "$(tput setaf 1)tc-job user NOT found in PAM  $(tput sgr0)")
fi


utccheck=$(ls -lrt /etc/localtime | awk '{print $11}' | rev | cut -d '/' -f1 | rev)
utccheckdif=$(ls -lrt /etc/localtime | awk '{print $11}' | rev | cut -d '/' -f1 | rev)
if [ $utccheck == 'UTC' ]
then
        utccheckok=$(echo "$(tput setaf 2)Timezone is set to UTC $(tput sgr0)")
else
        utccheckok=$(echo "$(tput setaf 3)Timezone is set to $utccheckdif $(tput sgr0)")
fi

limit1=$(grep redis /etc/security/limits.conf | awk '{print $4}')
if [ -z "$limit1" ]
then
        limit1ok=$(echo "$(tput setaf 1)Redis limits not set to 10000$(tput sgr0)")
else
        limit1ok=$(echo "$(tput setaf 2)Redis limits set to 10000$(tput sgr0)")
fi

tclimits=$(grep threatconnect /etc/security/limits.conf | awk '{print $4}')
if [ -z "$tclimits" ]
then
        limit2ok=$(echo "$(tput setaf 1)Threatconnect limits not set to 150000 $(tput sgr0)")
else
        limit2ok=$(echo "$(tput setaf 2)Threatconnect limits set to 150000 $(tput sgr0)")
fi

tcjblimits=$(grep tc-job /etc/security/limits.conf | awk '{print $4}')
if [ -z "$tcjblimits" ]
then
        limit3ok=$(echo "$(tput setaf 1)TC-JOB limits not set to 10000 $(tput sgr0)")
else
        limit3ok=$(echo "$(tput setaf 2)TC-JOB limits set to 10000$(tput sgr0)")
fi

fslimits=$(grep "file-max" /etc/sysctl.conf | awk '{print $3}')
if [ -z "$fslimits" ]
then
        limit4ok=$(echo "$(tput setaf 1)File Max limits not set to 150000 $(tput sgr0)")
else
        limit4ok=$(echo "$(tput setaf 2)File Max limits set to 150000 $(tput sgr0)")
fi

diskusage=$(df -h /opt/threatconnect | awk 'NR==2 {print $5}' | sed 's/%//g')
if [ $diskusage -gt "80" ]
then
        disku=$(echo "$(tput setaf 1)Disk Usage $diskusage $(tput sgr0)")
else
        disku=$(echo "$(tput setaf 2)Disk Usage $diskusage $(tput sgr0)")
fi

redisrun=$(ps -ef | grep 6379 | grep -U redis | awk 'NR==1 {print $9}')
if [ $redisrun == '127.0.0.1:6379' ]
then
        redisrunok=$(echo "$(tput setaf 2)Redis is running on $redisrun $(tput sgr0)")
else
        redisrunok=$(echo "$(tput setaf 1)Redis is down or running on another port $(tput sgr0)")
fi

tcservice=$(ls /etc/init.d/threatconnect)
if [ -z "$tcservice" ]
then
        tcserviceok=$(echo "$(tput setaf 1)The Threatconnect service is absent $(tput sgr0)")
else
        tcserviceok=$(echo "$(tput setaf 2)The Threatconnect service is set $(tput sgr0)")
fi


versiontc=$(cat /opt/threatconnect/app/version.txt | cut -d '=' -f2)

if [ $versiontc == "6.1.0" ]
then
        versiontcok=$(echo "$(tput setaf 5) $versiontc $(tput sgr0)")
else
        versiontcok=$(echo "$(tput setaf 2) $versiontc $(tput sgr0)")
fi


permsite=$(stat -c "%a %n" -- /usr/local/lib/python3.6/site-packages | awk {'print $1'})
permlib=$(stat -c "%a %n" -- /usr/local/lib/python3.6/lib2to3 | awk {'print $1'})

if [ $permsite == '755' ]
then
        permsiteok=$(echo "$(tput setaf 2) $permsite $(tput sgr0)")
else
        permsiteok=$(echo "$(tput setaf 1) $permsite $(tput sgr0)")
fi

if [ $permlib == '755' ]
then
        permlibok=$(echo "$(tput setaf 2) $permlib $(tput sgr0)")
else
        permlibok=$(echo "$(tput setaf 1) $permlib $(tput sgr0)")
fi

tcusername=$(echo "$(tput setaf 2) threatconnect $(tput sgr0)")
tcpathinst=$(echo "$(tput setaf 2) /opt/threatconnect $(tput sgr0)")

pidfile=$/opt/threatconnect/app/threatconnect.pid
if [ -z "$pidfile" ]; then
    tcrunncheckok=$(echo "$(tput setaf 1) Not Running $(tput sgr0)")    
 else
	tcrunncheckok=$(echo "$(tput setaf 2) Running $(tput sgr0)")
fi

tcerrors=$(grep ERROR /opt/threatconnect/app/log/server.log | wc | awk {'print $1'})

if [ $tcerrors -lt "50" ]
then
        tcerrorok=$(echo "$(tput setaf 2) $tcerrors $(tput sgr0)")
else
        tcerrorok=$(echo "$(tput setaf 1) $tcerrors $(tput sgr0)")
fi

tcerrors2=$(grep ERROR /opt/threatconnect/app/log/server.log | wc | awk {'print $1'})

if [ $tcerrors2 -lt "50" ]
then
        tcerrorok2=$(echo "$(tput setaf 2) $tcerrors2 $(tput sgr0)")
else
        tcerrorok2=$(echo "$(tput setaf 1) $tcerrors2 $(tput sgr0)")
fi

javaversok=$(java --version | awk 'NR==1 {print $2}')

if [ -z "$javaversok" ]
then
        javaversok2=$(echo "$(tput setaf 1) Java Not Installed $(tput sgr0)")
else
		javaversok2=$(echo "$(tput setaf 2) $javaversok $(tput sgr0)")
fi

javapathinst=$(grep "JAVA_HOME" /home/threatconnect/.bashrc)

if [ -z "$javapathinst" ]
then
		javapathinst2=$(echo "$(tput setaf 1) Java Not Installed $(tput sgr0)")
else
		javapathinst2=$(echo "$(tput setaf 2) $javapathinst $(tput sgr0)")
fi

clear
echo
        echo
                echo -e "                       *******************************************************************************************
                        \e[38;5;208m               SYSTEM INFORMATIONS\e[0m
                        -------------------------------------------------------------------------------------------
                        Operating system : \e[40;38;5;82m $(cat /etc/*-release | awk NR==1) \e[0m)
                        Memory :  \e[40;38;5;82m $(free -m | awk 'NR==2 {print $2}') \e[0m
                        *******************************************************************************************
                        \e[38;5;208m                      PYTHON\e[0m
                        Version : \e[32m $pyth \e[0m
                        Permissions on site-packages : $permsiteok
                        Permissions on lib2to3 : $permlibok
                        -------------------------------------------------------------------------------------------
                        \e[38;5;208m                      TCEX\e[0m
                        Version : \e[40;38;5;82m $tcex \e[0m
                        *******************************************************************************************
                        \e[38;5;208m                      JAVA\e[0m
                        -------------------------------------------------------------------------------------------
                        Version : $javaversok2
                        PATH : $javapathinst2
                        *******************************************************************************************
                        \e[38;5;208m                    REDIS SERVER\e[0m
                        -------------------------------------------------------------------------------------------
                        Redis server version : $redisver
                        Redis listen on : $redisrunok
                        Redif Conf Samples : \e[32m $sample \e[0m
                        Redis Conf allkeys : \e[32m $allkeys \e[0m
                        Redis Conf Memory : \e[32m $mem \e[0m
                        Redis Service User : \e[32m $user \e[0m
                        Redis com line : \e[32m $com1 \e[0m
                        Redis su line : \e[32m $com2\e[0m
                        Overcommit : $overcoredok
                        Disable THP : $thpredisok
                        Raise somaxconn above 511 : $somaxconntcok
                        *******************************************************************************************
                        \e[38;5;208m                    System Settings\e[0m
                        -------------------------------------------------------------------------------------------
                        limits.conf (Redis) : $limit1ok
                        limits.conf (TC) : $limit2ok
                        limits.conf (tc-job) : $limit3ok
                        sysctl.conf (File Max) : $limit4ok
                        PAM : $pamtcok
                        PAM tc-job : $pamtcjobok
                        Local Time : $utccheckok
                        *******************************************************************************************
                        \e[38;5;208m                    Threatconnect\e[0m
                        -------------------------------------------------------------------------------------------
                        Threatconnect Version : $versiontcok
                        Threatconnect Running : $tcrunncheckok
                        Server (server.log) Errors : $tcerrorok
			Threatconnect (tc.log) Errors : $tcerrorok2
                        Threatconnect Service : $tcserviceok
                        Threatconnect Base Dir : $tcpathinst
			Threatconnect User : $(grep threatconnect /etc/passwd | cut -f 1 -d ":")
                        Threatconnect Disk Usage : $disku%
                        *******************************************************************************************  "
                echo
        echo

        #pause "Press [Enter] key to continue..."
        pause

}




# Purpose - Get input via the keyboard and make a decision using case..esac
function read_input(){
        local c
        echo
        echo
        read -p "Enter your choice [ 1 - 17 ] " c
        case $c in
                1)      sys_info ;;
                17)     echo "Bye!"; exit 0 ;;
                *)
                        echo "Please select between 1 to 17 choice only."
                        pause
        esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap
#trap '' SIGINT SIGQUIT SIGTSTP

# main logic
while true
do
        clear
        show_menu       # display memu
        read_input  # wait for user input
done
