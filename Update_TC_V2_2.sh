#!/bin/bash
#############################################################################################
#|__   __| |  | |  __ \|  ____|   /\|__   __/ ____/ __ \| \ | | \ | |  ____/ ____|__   __|  #
#    | |  | |__| | |__) | |__     /  \  | | | |   | |  | |  \| |  \| | |__ | |       | |    #
#    | |  |  __  |  _  /|  __|   / /\ \ | | | |   | |  | | . ` | . ` |  __|| |       | |    #
#    | |  | |  | | | \ \| |____ / ____ \| | | |___| |__| | |\  | |\  | |___| |____   | |    #
#    |_|  |_|  |_|_|  \_\______/_/    \_\_|  \_____\____/|_| \_|_| \_|______\_____|  |_|    #
#                                                                                           #
#############################################################################################
##                                                                                          #                                                                                      
# THREATCONNECT    ---- ONLY FOR LEONARDO ------                                                                  		#
#"""""""""""""""""""""""""                                                                  #                                                                    
# Created by:  Seb THEIS |      21/09/2021 													#
# stheis@threatconnect.com                                                 					#                                                           
#.........................                                                                  #                                                                    
#                                                                                           #                                                                                            
# 1.) Update Threatconnect (TC SERVER)"														#
# 2.) Update Database (DB SERVER)"															#
# 3.) Update Elasticsearch (ES SERVER)"														#
# 4.) Fix SSL=False JDBC (TC SERVER)"														#
#                       					                                                #                                                                            
#                                                                                           #                                              
#                                                                                           #                                                                                            
#                                                                                           #                                                                                            
#                                                                                           #                                                                                            
#############################################################################################

#TC SERVER
#Backup xml
#Backup app directory
#Fix SSL to False in XML
#Fix the service file
#Reload the service daemon
#Deploy the last TC Version
#Check and fix permissions
#Fix sh scripts to be executables
#
#DB SERVER
#Dump database in specific directory
#Check Database size
#Check storage available on the chosen directory
#Update from 6.0.0 to 6.3
#Update from 6.0.1 to 6.3
#Update from 6.0.2 to 6.3
#Update from 6.0.3 to 6.3
#Update from 6.0.4 to 6.3
#Update from 6.0.5 to 6.3
#Update from 6.0.6 to 6.3
#Update from 6.0.7 to 6.3
#Update from 6.0.8 to 6.3
#Update from 6.1.0 to 6.3
#Update from 6.1.1 to 6.3
#Update from 6.2.0 to 6.3
#Update from 6.2.1 to 6.3
#
#ES SERVER
#Update ES RPM to 7.7
#Remove ingest attachment 6.3
#Install Ingest Attachment 7.7
#Configure YML file
#Reload service daemon
#Restart Elasticsearch

function press_enter(){
echo
echo
message="Press [Enter] key to continue... or CTRL+C to exit"
echo
echo
read -p "$message" readEnterKey
clear
}

function update_tc () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				UPDATE SCRIPT
						
			THREATCONNECT SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		

		"MAKE SURE THREATCONNECT IS NOT RUNNING"
	
		"MAKE SURE THREATCONNECT USERNAME IS PRESENT"
	
			"OTHERWISE PRESS CTRL+C"
	
	*****************************************************************
	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Press enter to continue"
	read -p "Please indicate the PATH of Threatconnect directory ? [/opt/threatconnect] : "  tc_installation
	versiontc=$(cat $tc_installation/app/version.txt | cut -f 2 -d "=")
	clear
	echo "***********************************"
	echo "You are running Version $versiontc"
	echo "***********************************"
	read -p "Press enter to continue"
	mv $tc_installation/app $tc_installation/app_$versiontc
	echo "-----------------------------------"
	echo "app backup done"
	echo "-----------------------------------"
	cp $tc_installation/config/threatconnect.xml $tc_installation/config/threatconnect.xml_$versiontc
	echo "-----------------------------------"
	echo "threatconnect.xml backup done"
	echo "-----------------------------------"
	cp -r app $tc_installation
	echo "-----------------------------------"
	echo "Version 6.0.3 deployed"
	echo "-----------------------------------"
	chown -R threatconnect:threatconnect $tc_installation/app
	echo "-----------------------------------"
	echo "chmod +x TC scripts"
	echo "-----------------------------------"
	chmod +x $tc_installation/app/*.sh
	chown -R threatconnect:threatconnect $tc_installation/config/*
	echo "-----------------------------------"
	echo "Permissions updated"
	echo "-----------------------------------"
	sed -i '/PIDFILE/s/app\/threatconnect.pid/app\/wildfly\/threatconnect.pid/' $tc_installation/app/service/threatconnect
	cp $tc_installation/app/service/threatconnect /etc/init.d/threatconnect
	systemctl daemon-reload
	echo "-----------------------------------------"
	echo "Service file updated and daemon reloaded"
	echo "-----------------------------------------"
	read -p "Press enter to continue"
	clear
	versiontc=$(cat $tc_installation/app/version.txt | cut -f 2 -d "=")
	echo "*************************************************"
	echo "You are running Version $versiontc"
	echo "*************************************************"
	echo "Run the setup.sh script since you updated the DB"
	echo "*************************************************"
	
}

function mysql_update600 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.0 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.0_to_6.0.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.1_to_6.0.2.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.2_to_6.0.3.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.3_to_6.0.4.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.4_to_6.0.5.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update601 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.1 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.1_to_6.0.2.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.2_to_6.0.3.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.3_to_6.0.4.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.4_to_6.0.5.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update602 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.2 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.2_to_6.0.3.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.3_to_6.0.4.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.4_to_6.0.5.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update603 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.3 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.3_to_6.0.4.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.4_to_6.0.5.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update604 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.4 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.4_to_6.0.5.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}


function mysql_update605 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.5 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			read -p "Press enter to Update the Database"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.5_to_6.0.6.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update606 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.6 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.6_to_6.0.7.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update607 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.7 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.7_to_6.0.8.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update608 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.0.8 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.0.8_to_6.1.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update61 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.1 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.0_to_6.1.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$password" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update611 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.1.1 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.1.1_to_6.2.0.sql
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

function mysql_update62 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.2 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.2.0_to_6.2.1.sql
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}

	
	function mysql_update621 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				VERSION 6.2.1 ONLY
				
				DATABASE SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m		
		"MAKE SURE THREATCONNECT IS NOT RUNNING"

			"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	echo ""
	echo ""
	read -p "Enter a directory with enough space available that will be used to Dump the MySQL Database [Ex : /tmp] :" mysqldumpdir
	echo ""
	echo ""
	unset password
	prompt="Enter Password:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
	done
		if [ -z "$prompt" ] ;  then
			printf "\nAborting Database creation\n"
        else
			clear
			echo "*********************************************************************************"
			echo "Make sure you have enough space on the directory you choose to dump the database"
			echo "*********************************************************************************"
			echo ""
			echo 'select TABLE_SCHEMA , ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" from information_schema.TABLES where TABLE_SCHEMA = "threatconnect";' | mysql -u root -p$password
			echo ""
			df -h $mysqldumpdir
			echo ""
			read -p "Press enter to continue or CTRL + C to quit"
			echo "**********************"
			echo "DUMPING THE DATABASE"
			echo "**********************"
			mysqldump --user=root -p$password threatconnect > $mysqldumpdir/threatconnect_`date +%F`.sql
			echo "***************"
			echo "DUMP COMPLETED"
			echo "***************"
			ls -lh $mysqldumpdir/threatconnect_`date +%F`.sql
			echo ""
			echo "PRESS ENTER TO UPDATE THE DATABASE"
			mysql -u root --password="$sqlpass" threatconnect --verbose < upgrade/6.2.1_to_6.3.0.sql			
		fi	
}
function esinst7 () {
	clear
	echo  -e ' \e[38;5;208m
	*****************************************************************
	*****************************************************************
		
				UPDATE SCRIPT
				
				ELASTIC SERVER ONLY
		
	*****************************************************************
	*****************************************************************\e[0m'
echo -e ' \033[0;31m			
				"OTHERWISE PRESS CTRL+C"

	*****************************************************************\e[0m'
	es_service=$(service elasticsearch status | awk 'NR==3 {print $2}')
	firewalldactive=$(systemctl status firewalld | awk 'NR==3{print $2}')
	echo ""
	echo ""
			if [ $es_service == 'active' ] ; then
					systemctl stop elasticsearch
					echo "Stopping Elasticsearch Service..."
					sleep 10
					rpm -Uvh elasticsearch-7.7.1-x86_64.rpm
					ip addr show
					read -p "Please enter the Ip Address of the server (x.x.x.x) : "  ipserv
					sed -i 's/#cluster.name.*/cluster.name: elasticTsearch/' /etc/elasticsearch/elasticsearch.yml
					sed -i 's/#network.host.*/network.host: '"$ipserv"'/' /etc/elasticsearch/elasticsearch.yml
					sed -i '/network.host.*/a http.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
					sed -i '/http.host.*/a transport.host: '"$ipserv"'' /etc/elasticsearch/elasticsearch.yml
					sed -i 's/#action.destruc.*/action.destructive_requires_name: true/' /etc/elasticsearch/elasticsearch.yml
					echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
				else
					rpm -Uvh elasticsearch-7.7.1-x86_64.rpm
					ip addr show
					read -p "Please enter the Ip Address of the server (x.x.x.x) : "  ipserv
					sed -i 's/#cluster.name.*/cluster.name: elasticTsearch/' /etc/elasticsearch/elasticsearch.yml
					sed -i 's/#network.host.*/network.host: '"$ipserv"'/' /etc/elasticsearch/elasticsearch.yml
					sed -i '/network.host.*/a http.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
					sed -i '/http.host.*/a transport.host: '"$ipserv"'' /etc/elasticsearch/elasticsearch.yml
					sed -i 's/#action.destruc.*/action.destructive_requires_name: true/' /etc/elasticsearch/elasticsearch.yml
					echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
			fi

		if [ $firewalldactive != 'active' ] ; then
			systemctl enable firewalld
			systemctl start firewalld
			firewall-cmd --permanent --zone=public --add-port=9200/tcp
			firewall-cmd --permanent --zone=public --add-port=9300/tcp
			firewall-cmd --reload
		else
			firewall-cmd --permanent --zone=public --add-port=9200/tcp
			firewall-cmd --permanent --zone=public --add-port=9300/tcp
			firewall-cmd --reload
		fi
			/usr/share/elasticsearch/bin/elasticsearch-plugin remove ingest-attachment
			
			echo "Ingest Attachement plugin for 6.3 removed"
			read -p "Press enter to continue"
			cp ingest-attachment-7.7.1.zip /tmp
			/usr/share/elasticsearch/bin/elasticsearch-plugin install file:/tmp/ingest-attachment-7.7.1.zip
			read -p "Press enter to continue"			
			service elasticsearch start
			echo "-----------------------------------------"
			echo "		Starting Elasticsearch"
			echo "-----------------------------------------"
			sleep 5
			service elasticsearch status
}

function fixjdbcssl () {
read -p "Please indicate the PATH of Threatconnect directory ? [/opt/threatconnect] : "  tc_installation
cp $tc_installation/config/threatconnect.xml $tc_installation/config/threatconnect.xml_pre_fix
sed -i 's/rewriteBatchedStatements=true/&\&amp;useSSL=false/' $tc_installation/config/threatconnect.xml
echo "------------------------------------------------------------------"
echo "		SSL Fixed on JDBC connector"
echo "------------------------------------------------------------------"
echo "Run this sequence only if the setup.sh has been already executed"
echo "------------------------------------------------------------------"
}

function update_database
{
 option=0
until [ "$option" = "14" ]; do
echo  -e ' \e[38;5;208m
  _______ _                    _                                  _   
 |__   __| |                  | |                                | |  
    | |  | |__  _ __ ___  __ _| |_ ___ ___  _ __  _ __   ___  ___| |_ 
    | |  | '_ \| '__/ _ \/ _` | __/ __/ _ \| '_ \| '_ \ / _ \/ __| __|
    | |  | | | | | |  __/ (_| | || (_| (_) | | | | | | |  __/ (__| |_ 
    |_|  |_| |_|_|  \___|\__,_|\__\___\___/|_| |_|_| |_|\___|\___|\__|\e[0m'
echo ""	
echo ""
echo "  !!!!!!!!*****UPDATE SCRIPT*****!!!!!!!!! "
echo ""
echo ""	
echo ""
echo "  1.) Update from 6.0.0 to 6.3"
echo "  2.) Update from 6.0.1 to 6.3"
echo "  3.) Update from 6.0.2 to 6.3"
echo "  4.) Update from 6.0.3 to 6.3"
echo "  5.) Update from 6.0.4 to 6.3"
echo "  6.) Update from 6.0.5 to 6.3"
echo "  7.) Update from 6.0.6 to 6.3"
echo "  8.) Update from 6.0.7 to 6.3"
echo "  9.) Update from 6.0.8 to 6.3"
echo "  10.) Update from 6.1.0 to 6.3"
echo "  11.) Update from 6.1.1 to 6.3"
echo "  12.) Update from 6.2.0 to 6.3"
echo "  13.) Update from 6.2.1 to 6.3"
echo "  14.) Quit"
echo ""
echo -n "Enter choice: "
read option
echo ""
 case $option in
 1 ) mysql_update600; press_enter ;;
 2 ) mysql_update601; press_enter ;;
 3 ) mysql_update602; press_enter ;;
 4 ) mysql_update603; press_enter ;;
 5 ) mysql_update604; press_enter ;;
 6 ) mysql_update605; press_enter ;;
 7 ) mysql_update606; press_enter ;;
 8 ) mysql_update607; press_enter ;;
 9 ) mysql_update608; press_enter ;;
 10 ) mysql_update61; press_enter ;;
 11 ) mysql_update611; press_enter ;;
 12 ) mysql_update62; press_enter ;;
 13 ) mysql_update621; press_enter ;;
 14 ) main_menu; press_enter ;;
 15 ) break ;;
 * ) tput setf 3;echo "Please enter 1, 2 , 3, 4, 5, 6, 7 ,8 ,9 ,10 ,11, 12 , 14 or 13 ";tput setf 3; 
 esac
#   }
 done
}


function main_menu 
{
option=0
until [ "$option" = "5" ]; do
echo  -e ' \e[38;5;208m
  _______ _                    _                                  _   
 |__   __| |                  | |                                | |  
    | |  | |__  _ __ ___  __ _| |_ ___ ___  _ __  _ __   ___  ___| |_ 
    | |  | '_ \| '__/ _ \/ _` | __/ __/ _ \| '_ \| '_ \ / _ \/ __| __|
    | |  | | | | | |  __/ (_| | || (_| (_) | | | | | | |  __/ (__| |_ 
    |_|  |_| |_|_|  \___|\__,_|\__\___\___/|_| |_|_| |_|\___|\___|\__|\e[0m'
echo ""	
echo ""
echo "  !!!!!!!!*****UPDATE SCRIPT*****!!!!!!!!! "
echo ""	
echo ""
echo "  1.) Update Threatconnect (TC SERVER)"
echo "  2.) Update Database (DB SERVER)"
echo "  3.) Update Elasticsearch (ES SERVER)"
echo "  4.) Fix SSL=False JDBC (TC SERVER)"
echo "  5.) Quit"
echo ""
echo -n "Enter choice: "
read option
echo ""
case $option in
    1 ) clear ; update_tc ; press_enter ;;
    2 ) clear ; update_database  ; press_enter ;;
    3 ) clear ; esinst7 ; press_enter ;;
	4 ) clear ; fixjdbcssl ; press_enter ;;
    5 ) exit;;
    * ) tput setf 4;echo "Please enter 1, 2, 3, 4 or 5";tput setf 4; 
esac
done
 }

main_menu
