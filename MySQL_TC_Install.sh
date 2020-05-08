#!/bin/bash

##Instructions for setting up the TC MySQL Server

##RAM to allocate to MySQL

mem="$(free -m | awk 'NR==2 {print $2}')"
buffervarpre="$(awk -vn=$mem 'BEGIN{printf("%.0f\n",n*0.8)}')"
buffervar="$(( $buffervarpre * 1024*1024 ))"
echo "Configuring InnoDB Buffer Pool Size with a size of ${buffervar}"

##Root password for MySQL
	read -sp 'Please provide the password you would like the MySQL root account to be: ' mysqlrootvar
	echo
	echo
	
##tcuser password for MySQL
	read -sp 'Please provide the password you would like the MySQL tcuser account to be: ' mysqltcuservar
	echo
	echo
	
##Set UTC timezone
echo
printf "\e[1mChanging to UTC timezone\e[0m\n"
yes | cp /usr/share/zoneinfo/UTC /etc/localtime


##Install MySQL 
echo
printf "\e[1mInstalling required dependencies\e[0m\n"
cd /tmp/
yum install -y -d1 wget which unzip firewalld
echo
printf "\e[1mDownloading MySQL Repo\e[0m\n"
wget http://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
rpm -ivh mysql57-community-release-el7-11.noarch.rpm
echo
printf "\e[1mInstalling MySQL Server\e[0m\n"
yum install -y -d1 mysql-server 
echo
printf "\e[1mStarting MySQL Service\e[0m\n"
systemctl start mysqld


#Pull temporary MySQL root password from log 
mysqltemprootvar="$(grep "temporary password" /var/log/mysqld.log | fgrep 'root@localhost:' | awk '{ print $NF }')"

##Change MySQL temp root password to user input password
echo
printf "\e[1mChanging to MySQL temp root password to user supplied password\e[0m\n"
mysqladmin --user=root --password=$mysqltemprootvar password "$mysqlrootvar"


##Commands to secure MySQL and create ThreatConnect Database and tcuser 
echo
printf "\e[1mRunning MySQL Secure Installation\e[0m\n"
mysql -uroot -p$mysqlrootvar -e "DELETE FROM mysql.user WHERE User=''"
mysql -uroot -p$mysqlrootvar -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -uroot -p$mysqlrootvar -e "DROP DATABASE IF EXISTS test"
mysql -uroot -p$mysqlrootvar -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
echo
printf "\e[1mCreating ThreatConnect Database\e[0m\n"
mysql -uroot -p$mysqlrootvar -e "CREATE DATABASE threatconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
echo
printf "\e[1mCreating ThreatConnect MySQl user and applying permissions\e[0m\n"
mysql -uroot -p$mysqlrootvar -e "CREATE USER 'tcuser'@'%' IDENTIFIED BY '$mysqltcuservar'"
mysql -uroot -p$mysqlrootvar -e "GRANT ALL PRIVILEGES ON threatconnect.* TO 'tcuser'@'%' IDENTIFIED BY '$mysqltcuservar'"
mysql -uroot -p$mysqlrootvar -e "FLUSH PRIVILEGES"


##Config Changes to /etc/my.cnf under [mysql] section:
echo
printf "\e[1mBacking up default MySQL Configuration File\e[0m\n"
cp /etc/my.cnf /etc/my.cnf.original
echo
printf "\e[1mUpdating MySQL Configuration File\e[0m\n"
sed -i '/\[mysqld\]/a \
## ThreatConnect Added Settings \
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION \
lower_case_table_names=1 \
character_set_server=utf8mb4 \
collation_server=utf8mb4_unicode_ci \
group_concat_max_len=1000000 \
transaction_isolation=READ-COMMITTED \
innodb_flush_log_at_trx_commit=2 \
innodb_table_locks=0 \
innodb_autoinc_lock_mode=2 \ 
eq_range_index_dive_limit=200 \
innodb_large_prefix=on \
innodb_file_format=barracuda \
innodb_buffer_pool_size=1G \
event_scheduler=1 \
innodb_lock_wait_timeout=500 \
innodb_buffer_pool_size='$buffervar'' /etc/my.cnf


##Update firewall-cmd to allow traffic
echo
printf "\e[1mSetting up Firewall and Rules\e[0m\n"
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=public --add-service=mysql
firewall-cmd --reload


##Restart to apply changes
echo
printf "\e[1mRestarting MySQL to apply new changes\e[0m\n"
systemctl restart mysqld
echo

##Create ThreatConnect Tables and permissions
printf "\e[1mImporting ThreatConnect Script into MySQL Database\e[0m\n"
mysql -uroot -p$mysqlrootvar threatconnect < /tmp/ThreatConnect-6.0.2.sql


##Flushing secure variables
echo
printf "\e[1mClearing Variables used in script\e[0m\n"
mysqltemprootvar=00000000000
mysqlrootvar=00000000000
mysqltcuservar=00000000000

exit 0


