#!/bin/bash


# Purpose: Display pause prompt
# $1-> Message (optional)
function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}


function show_menu(){
    date
    echo "---------------------------"
    echo "  Threatconnect Tool Menu"
    echo "---------------------------"
	echo "1. OS Version Check"
	echo "2. MySQL Database Backup"
	echo "3. MySQL Version Check"
	echo "4. Stopping MySQL Service"
	echo "5. Starting MySQL Service"
	echo "6. TC Admin Password Reset"
	echo "7. exit"
}


function write_header(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "     ${h}"
	echo "---------------------------------------------------------------"
}

function os_info(){
	write_header " System information "
	echo "Operating system : $(cat /etc/*-release | awk NR==1)"
	#pause "Press [Enter] key to continue..."
	pause
}

function mysqldump(){
	write_header " Please ensure that the Threatconnect application is stopped before launching this command "
	while read yn; do
	read -p "Are you sure you want to continue?" yn
		case "$yn" in
			"Y|y" ) mysqldump -u root -pPassword1! threatconnect > /tmp/threatconnect_`date +%F`.sql ; break ;;
			"N|n" ) exit ;;
			* ) echo "Please answer yes or no.";;
		esac
	done
	#mysqldump -u $mysqlusr -p$mysqlpasswd $mysqldb | gzip > /tmp/threatconnect_`date +%F`.sql.gz
	#mysqldump --opt --user=${mysqlusr} --password=${mysqlpasswd} ${mysqldb} > /tmp/threatconnect_`date +%F`.sql
	ls -lrt /tmp/threatconnect_`date +%F`.sql
	pause
}




function mysql_info(){
	write_header " MYSQL Information "
	echo "MySQL Version : $(mysqld --version | awk '{print $3}')"

	pause 
}
  
function mysql_service(){
	local cmd="$1"
	case "$cmd" in 
		stop) write_header " Stop MySQL Service "; systemctl stop mysqld ; pause ;;
		start) write_header " Start MySQL Service "; systemctl start mysqld ; pause ;;
	esac 
}

function mysqladminreset(){
	write_header " Backup of the MySQL Database "
	read -p 'Please provide the username for MySQL: ' mysqlusr
	echo -e
	read -sp 'Please provide the password for MySQL: ' mysqlpasswd
	echo -e
	read -p 'Please provide the database for MySQL: ' mysqldb
	mysql -u$mysqlusr -p$mysqlpasswd -D $mysqldb -e "UPDATE User SET password = 'JiNeQHkKWKmFtqcCT9GTLyWDO+ViMaA4kJHa6/7CBbo=', salt = '7173744076097521289', locked = 0, resetRequired = 1, failedAttempts = 0, lastFailedAttempt = NULL, disabled = 0, authenticatorSecretKey = NULL WHERE userName = 'admin'"
	echo "Your Password is now "password1""
	pause
}

# Purpose - Get input via the keyboard and make a decision using case..esac 
function read_input(){
	local c
	read -p "Enter your choice [ 1 - 7 ] " c
	case $c in
		1)	os_info ;;
		2)	mysqldump "dump" ;;
		3)	mysql_info ;;
		4)	mysql_service "stop" ;;
		5)	mysql_service "start" ;;
		6)	mysqladminreset ;;
		7)	echo "Bye!"; exit 0 ;;
		*)	
			echo "Please select between 1 to 7 choice only."
			pause
	esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap
#trap '' SIGINT SIGQUIT SIGTSTP

# main logic
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done