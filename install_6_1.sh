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
#                       2)      Install Python 3.6.8                                                                                                                            #
#                       3)      Update TCEX 2.0                                                                                                                                 #
#                       4)      Install Redis 5                                                                                                                                         #
#                       5)      Set timezone to UTC                                                                                                                             #
#                       6)  Setup TC Environment Variables                                                                                              #
#                       7)  Install Java 11                                                                                                                             #
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
                echo -e                               "\e[40;38;5;82m                                  		 1. System Check
                                        2. Install Python 3.6.8
                                        3. Install TCEX
                                        4. Install JDK 11
                                        5. Install Redis 5
                                        6. Prepare TC Env
                                        7. Set Timezone to UTC
                                        8. Create TC service
                                        9. Install MySQL server
                                        10. MySQL Config
                                        11. MySQL DB/User Creation
					12. Install Postgres server
                                        13. Postgres Config
					14. Postgres DB/User Creation
					15. ES 7.7 Installation
					16. ES 7.7 Plugin Install
                                        17. exit\e[0m"
}

function write_header(){
        local h="$@"
        echo "---------------------------------------------------------------"
        echo "     ${h}"
        echo "---------------------------------------------------------------"
}



function Python () {
clear
yum groupinstall "Development Tools"
yum -y install wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel python-setuptools
read -p "Do you want to download the Python Binary ? [yes/no] : "  pyconf
        if [ $pyconf == 'yes' ] ; then
                        wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz
        else
                        read -p "Where is located your python binary ? [PATH] : "  pythonpath
        fi

        if [ $pyconf == 'yes' ] ; then
                        tar xf Python-3.6.8.tar.xz
                        cd Python-3.6.8
                        clear
                        printf "Starting Compilation\n"
                        ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
                        pause
                        make
                        make altinstall
                        ln -s /usr/local/bin/python3.6 /usr/local/bin/python
        else
                        cd $pythonpath
                        tar xf Python-3.6.8.tar.xz
                        cd Python-3.6.8
                        clear
                        printf "Starting Compilation\n"
                        ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
                        pause
                        make
                        make altinstall
                        ln -s /usr/local/bin/python3.6 /usr/local/bin/python
        fi
}

function installTcex () {
clear
pythpath=$(which python3.6)
pause

        if [ $pythpath == '/usr/local/bin/python3.6' ]  ; then
                                echo
                                echo
                         printf "Updating permissions\n"
                                echo
                         chmod -R 755 /usr/local/lib/python3.6/site-packages
                         chmod -R 755 /usr/local/lib/python3.6/lib2to3
                                printf "Getting TCEX\n"
                        /usr/local/bin/pip3.6 install tcex
        else
                        read -p "Where is installed Python3.6 binary [PATH] : " pythpath
                        read -p "Where are installed the Python3.6 lib [PATH] : " pythlibpath
                        printf "Updating permissions\n"
                                echo
                        chmod -R 755 $pythlibpath/python3.6/site-packages
                        chmod -R 755 $pythlibpath/python3.6/lib2to3
                                printf "Getting TCEX\n"
                        $pythpath/pip3.6 install tcex
fi
}

function installJava () {
				useradd threatconnect
				tcusername=$(grep threatconnect /etc/passwd | cut -f 1 -d ":")
        if [ $tcusername == 'threatconnect' ] ; then
                yum -y install java-11-openjdk-devel
#               java11openjdk=$(alternatives --display java | grep 11 | awk 'NR==1{print $1}' | rev | cut -d '/' -f3- | rev)
                alternatives --set java "$java11openjdk"/"bin/java"
                java11openjdk=$(readlink -f /etc/alternatives/java  | rev | cut -d '/' -f3- | rev)
                pause
                echo JAVA_HOME=$java11openjdk >> /home/threatconnect/.bashrc
        else
                read -p "What is the username used to start Threatconnect? : "  tccustname
                yum -y install java-11-openjdk-devel
                java11openjdk=$(alternatives --display java | grep 11 | awk 'NR==1{print $1}' | rev | cut -d '/' -f3- | rev)
                alternatives --set java "$java11openjdk"/"bin/java"
                java11openjdk=$(readlink -f /etc/alternatives/java  | rev | cut -d '/' -f3- | rev)
                pause
                echo JAVA_HOME=$java11openjdk >> /home/$tccustname/.bashrc
fi
}



function installRedis5 () {
                yum -y install bison byacc cscope ctags cvs diffstat doxygen flex gcc gcc-c++ gcc-gfortran gettext git indent intltool libtool patch patchutils rcs redhat-rpm-config rpm-build tcl
                read -p "Do you want to download the Redis Binary ? [yes/no] : "  reddown

                if [ $reddown == 'yes' ] ; then
                                                redpwd=$(pwd)
                                                wget http://download.redis.io/releases/redis-5.0.9.tar.gz
                                                tar -xvzf redis-5.0.9.tar.gz
                                                cd redis-5.0.9
                                                cd deps/
                                                make hiredis lua jemalloc linenoise
                                                pause "Press [Enter] key to run make install..."
                                                cd ..
                                                make && make test
                                                pause
                                                make install
                                                echo " Redis is ready to be installed , please run cd utils/ - ./install_server.sh "
                                                pause "Press [Enter] key to install Redis..."
                                                cd $redpwd/redis-5.0.9/utils
                                                ./install_server.sh
                                                pause "Redis has been installed - Press [Enter] key to continue and to update system files..."
                                                printf "Creating Service\n"
                                                cp /tmp/6379.conf /etc/init.d/redis_6379.conf
                                                printf "Editing redis_6379.conf file\n"
                                                sed -i -e "\$amaxmemory 6gb" /etc/redis/6379.conf > /dev/null
                                                sed -i -e "\$amaxmemory-policy allkeys-lru" /etc/redis/6379.conf > /dev/null
                                                sed -i -e "\$amaxmemory-samples 5" /etc/redis/6379.conf > /dev/null
                                                printf "Creating redis user\n"
                                                adduser redis > /dev/null
                                                printf "Adding USER=redis\n"
                                                sed -i -e '/REDISPORT=/a USER=redis' /etc/init.d/redis_6379 > /dev/null
                                                printf "Commenting $EXEC $CONF\n"
                                                sed -i -e '/$EXEC $CONF/s/^/#/' /etc/init.d/redis_6379 > /dev/null
                                                printf "Adding User Variable\n"
                                                sed -i -e '/$EXEC $CONF/a su - $USER -c "$EXEC $CONF"' /etc/init.d/redis_6379 > /dev/null
                                                sysctl -w net.core.somaxconn=512
                                                echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
                                                echo never > /sys/kernel/mm/transparent_hugepage/enabled
                                                printf "Updating permissions\n"
                                                chown -R redis:redis /var/lib/redis/ > /dev/null
                                                chown redis:redis /var/log/redis_6379.log > /dev/null
                                                chown -R redis:redis /etc/redis/ > /dev/null
                                                echo "Permissions Updated and user created"
                                                echo "Press [Enter] key to restart Redis."
                                                pause
                                                /etc/init.d/redis_6379 restart
                                                echo "Redis server version : $(redis-server --version | awk {'print $3'})"
                else
                                                read -p "Where is located your Redis Archive ? [PATH] : "  redbinpath
                                                cd $redbinpath
                                                tar -xvzf redis-5.0.9.tar.gz
                                                cd redis-5.0.9
                                                cd deps/
                                                make hiredis lua jemalloc linenoise
                                                pause "Press [Enter] key to run make install..."
                                                cd ..
                                                make && make test
                                                pause
                                                make install
                                                echo " Redis is ready to be installed , please run cd utils/ - ./install_server.sh "
                                                pause "Press [Enter] key to install Redis..."
                                                cd $redbinpath/redis-5.0.9/utils
                                                ./install_server.sh
                                                pause "Redis has been installed - Press [Enter] key to continue and to update system files..."
                                                printf "Creating Service\n"
                                                cp /tmp/6379.conf /etc/init.d/redis_6379.conf
                                                printf "Editing redis_6379.conf file\n"
                                                sed -i -e "\$amaxmemory 6gb" /etc/redis/6379.conf > /dev/null
                                                sed -i -e "\$amaxmemory-policy allkeys-lru" /etc/redis/6379.conf > /dev/null
                                                sed -i -e "\$amaxmemory-samples 5" /etc/redis/6379.conf > /dev/null
                                                printf "Creating redis user\n"
                                                adduser redis > /dev/null
                                                printf "Adding USER=redis\n"
                                                sed -i -e '/REDISPORT=/a USER=redis' /etc/init.d/redis_6379 > /dev/null
                                                printf "Commenting $EXEC $CONF\n"
                                                sed -i -e '/$EXEC $CONF/s/^/#/' /etc/init.d/redis_6379 > /dev/null
                                                printf "Adding User Variable\n"
                                                sed -i -e '/$EXEC $CONF/a su - $USER -c "$EXEC $CONF"' /etc/init.d/redis_6379 > /dev/null
                                                sysctl -w net.core.somaxconn=512
                                                echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
                                                echo never > /sys/kernel/mm/transparent_hugepage/enabled
                                                printf "Updating permissions\n"
                                                chown -R redis:redis /var/lib/redis/ > /dev/null
                                                chown redis:redis /var/log/redis_6379.log > /dev/null
                                                chown -R redis:redis /etc/redis/ > /dev/null
                                                echo "Permissions Updated and user created"
                                                echo "Press [Enter] key to restart Redis."
                                                pause
                                                /etc/init.d/redis_6379 restart
                                                echo "Redis server version : $(redis-server --version | awk {'print $3'})"

                fi
}


function installtcenv () {
                                                read -p "Do you want to download the Threatconnect Archive ? [yes/no] : "  tcdown608
                if [ $tcdown608 == 'yes' ] ; then
                                                wget https://tc-cs-app-delivery.s3.amazonaws.com/Deployments/threatconnect-v6.1.0.zip
                                                read -p "Where do you want to extract the Threatconnect Archive ? [ex : /opt] : "  extracttc
                                                unzip threatconnect-v6.1.0.zip -d $extracttc
                                                yum -y install firewalld
                                                chown -R threatconnect:threatconnect $extracttc/threatconnect
                else
                                                read -p "Where islocated the Threatconnect Archive ? [/PATH] : "  tcarchive
                                                read -p "Where do you want to extract the Threatconnect Archive ? [/PATH] : "  extracttc
                                                unzip $tcarchive/threatconnect-v6.0.8.zip -d $extracttc
                                                chown -R threatconnect:threatconnect $extracttc/threatconnect
                fi
                                                printf "\nAdding users and groups and setting permissions\n"
                                                useradd tc-job
                                                echo "tc-job-pass123" | passwd tc-job --stdin
                                                groupadd tc-job-read
                                                usermod -a -G tc-job-read tc-job
                                                chgrp -R tc-job-read $extracttc/threatconnect/exchange/programs
                                                chmod -R 755 $extracttc/threatconnect/exchange/programs
                                                groupadd tc-job-write
                                                usermod -a -G tc-job-write tc-job
                                                chgrp -R tc-job-write $extracttc/threatconnect/exchange/jobs
                                                chmod -R 777 $extracttc/threatconnect/exchange/jobs
                                                chmod +t $extracttc/threatconnect/exchange/jobs
                                                chown -R threatconnect:tc-job-read $extracttc/threatconnect/exchange/programs/organization/
                                                printf "\nConfiguring firewall rules\n"
                                                read -p "Are you using Firewalld or Ipdatble ? [firewalld/iptable] : "  firewalluse
                if [ $firewalluse == 'firewalld' ] ; then
                                                systemctl enable firewalld
                                                systemctl start firewalld
                                                firewall-cmd --permanent --zone=public --add-service=smtp
                                                firewall-cmd --permanent --zone=public --add-service=http
                                                firewall-cmd --permanent --zone=public --add-service=https
                                                firewall-cmd --permanent --zone=public --add-port=62000/tcp
                                                firewall-cmd --permanent --zone=public --add-forward-port=port=25:proto=tcp:toport=2500
                                                firewall-cmd --permanent --zone=public --add-forward-port=port=80:proto=tcp:toport=8080
                                                firewall-cmd --permanent --zone=public --add-forward-port=port=443:proto=tcp:toport=8443
                                                firewall-cmd --permanent --direct --add-rule ipv4 nat OUTPUT 0 -p tcp -o lo --dport 443 -j REDIRECT --to-ports 8443
                                                firewall-cmd --reload
                else
                                                iptables -t nat -A PREROUTING -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 8443
                                                iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
                                                iptables -t nat -A PREROUTING -p tcp -m tcp --dport 25 -j REDIRECT --to-ports 2500
                                                iptables -t nat -A OUTPUT -p tcp -o lo --dport 443 -j REDIRECT --to-ports 8443
                                                iptables -A INPUT -p tcp --dport 62000 -j ACCEPT
                fi


												touch /etc/sudoers.d/threatconnect
												echo 'Defaults:threatconnect !requiretty' >> /etc/sudoers.d/threatconnect
												echo 'threatconnect ALL=(tc-job) NOPASSWD: ALL' >> /etc/sudoers.d/threatconnect

												echo 'threatconnect - nofile 150000' >> /etc/security/limits.conf
                                                echo 'tc-job - nofile 10000' >> /etc/security/limits.conf
                                                echo 'redis - nofile 10000' >> /etc/security/limits.conf
                                                echo 'fs.file-max = 150000' >> /etc/sysctl.conf
                                                printf "\nConfiguring PAM\n"
                        #Update PAM configuration
                        echo '#%PAM-1.0
# ***********************************************************
#
# ThreatConnect Updated
#
# Date: '$DATE'
# installer: '$USER'
#
# ***********************************************************
auth        sufficient                  pam_rootok.so
auth        [success=ignore default=1]   pam_succeed_if.so         user = tc-job
auth        sufficient                  pam_succeed_if.so          use_uid      user = threatconnect
auth        sufficient                  pam_rootok.so
auth        substack                    system-auth
auth        include                     postlogin
account     sufficient                  pam_succeed_if.so uid = 0 use_uid quiet
account     include                     system-auth
password    include                     system-auth
session     include                     system-auth
session     include                     postlogin
session     optional                    pam_xauth.so' | tee /etc/pam.d/su

                        printf "\nAborting MEO Install\n"

}

function fixtime () {
localt=$(ls -lrt /etc/localtime | awk '{print $11}' | rev | cut -d '/' -f1 | rev)
    if [ $localt != 'UTC' ] ; then
                mv /etc/localtime /etc/localtime_backup
                ln -s /usr/share/zoneinfo/UTC /etc/localtime
                timedatectl set-timezone UTC
				echo "Timezone changed to $localt"
				pause
        else
				echo "Timezone already to $localt"
printf "\nAborting tc app install\n"
                fi

}

function installserv () {
read -p "What is the directory of Threatconnect ? [/opt/threatconnect] : " tcdirinst
if [ $USER == 'root' ] ; then
cp $tcdirinst/app/service/threatconnect /etc/init.d/
systemctl enable threatconnect.service
systemctl daemon-reload
else
                        printf "\nAborting tc app install\n"
                fi
}


function mysqlsetup () {
                                 read -p "Do you want to download MySQL57 rpm Archive ? [yes/no] : "  tcmysql
                if [ $tcmysql == 'yes' ] ; then
                                                yum -y install wget firewalld
                                                wget http://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
                                                rpm -ivh mysql57-community-release-el7-11.noarch.rpm
                                                yum install mysql-server firewalld -y
                                                firewall-cmd --permanent --zone=public --add-service=mysql
                                                firewall-cmd --reload
                                                systemctl enable mysqld
                                                systemctl start mysqld
                                                pause
                                                sqltemppass=$(grep "temporary password" /var/log/mysqld.log | rev | cut -d ":" -f1 | rev)
                                                echo -e "you temporary SQL password is $sqltemppass"
                                                mysql_secure_installation
                else
                                                read -p "Where is located the MySQL57 rpm Archive ? [/PATH] : "  tcarchive
												cd $tcarchive
                                                 rpm -ivh mysql57-community-release-el7-11.noarch.rpm
												yum install mysql-server -y
                                                systemctl enable mysqld
                                                systemctl start mysqld
                                                pause
                                                firewall-cmd --permanent --zone=public --add-service=mysql
                                                firewall-cmd --reload
                                                sqltemppass=$(grep "temporary password" /var/log/mysqld.log | rev | cut -d ":" -f1 | rev)
                                                echo -e "you temporary SQL password is $sqltemppass"
                                                mysql_secure_installation
                fi
}


function mysqlcustom2 () {
                                                                                                mem=$(free -g | awk 'NR==2 {print $2}')
                                                                                                mysqlmem=$(awk -v n="$mem" 'BEGIN{ print int(n*0.75) }')G
                                                                                                checkrunsql=$(ps -ef | grep mysql)
                                        if [ -z "$checkrunsql" ] ; then
                                        printf "\nAborting mysql config \n"
else

                echo '
                                        # For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION
lower_case_table_names=1
character_set_server=utf8mb4
collation_server=utf8mb4_unicode_ci
group_concat_max_len=1000000
transaction_isolation=READ-COMMITTED
innodb_flush_log_at_trx_commit=2
innodb_table_locks=0
innodb_autoinc_lock_mode=2
eq_range_index_dive_limit=200
innodb_large_prefix=on
innodb_file_format=barracuda
event_scheduler=1
innodb_lock_wait_timeout = 500' | tee /etc/my.cnf

                                        echo "innodb_buffer_pool_size=$mysqlmem" >> /etc/my.cnf
										systemctl restart mysqld

fi
}


function createdb () {
read -p "Enter the MySQL Root Password : "  sqlpass

if [ -z "$sqlpass" ] ;  then
                printf "\nAborting Database creation\n"
        else
                echo "CREATE DATABASE threatconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql -u root -p$sqlpass
                echo "CREATE USER 'tcuser'@'%' IDENTIFIED BY 'Password1!';" | mysql -u root -p$sqlpass
                echo "GRANT ALL PRIVILEGES ON threatconnect.* TO 'tcuser'@'%' IDENTIFIED BY 'Password1!';" | mysql -u root -p$sqlpass
                echo "FLUSH PRIVILEGES;" | mysql -u root -p$sqlpass
                pause
                mysql -u root --password="$sqlpass" threatconnect --verbose < ./mysql/ThreatConnect-6.1.sql
                fi

}


function psqlsetup () {
                                 read -p "Are you using Redhat or Centos ? [redhat/centos] : "  osused
                if [ $osused == 'redhat' ] ; then
                                                yum -y install firewalld
                                                yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                                                yum -y install postgresql11 postgresql11-server
												systemctl enable postgresql-11
                                                service firewalld start
												firewall-cmd --permanent --zone=public --add-service=postgresql
                                                firewall-cmd --reload
                                                systemctl start postgresql-11
												/usr/pgsql-11/bin/postgresql-11-setup initdb
                else
                                                yum -y install firewalld
                                                yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
                                                yum -y install postgresql11 postgresql11-server
												systemctl enable postgresql-11
                                                service firewalld start
												firewall-cmd --permanent --zone=public --add-service=postgresql
                                                firewall-cmd --reload
                                                systemctl start postgresql-11
												/usr/pgsql-11/bin/postgresql-11-setup initdb
                fi
}

function psqlcustom2 () {
checkrunpsql=$(ps -ef | grep postgres)
                                        if [ -z "$checkrunpsql" ] ; then
                                        printf "\nAborting psql config \n"
else
										mem=$(free -g | awk 'NR==2 {print $2}')
                                        psqlmem=$(awk -v n="$mem" 'BEGIN{ print int(n*0.75) }')G
										psqlmem2=$(awk -v n="$mem" 'BEGIN{ print int(n*0.75) }')
										psqlcache=$(awk -v n="$psqlmem2" 'BEGIN{ print int(n*0.75) }')
										ipserv=$(ifconfig eth0 | awk 'NR==2 {print $2}')
										cpucore=$(nproc)
										cpucore2=$(echo "$cpucore-1" |bc)
										read -p "please enter the IP of the Threatconnect server ? : "  tcipserv
                                        sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'Password01';"
										cp /var/lib/pgsql/11/data/pg_hba.conf /var/lib/pgsql/11/data/pg_hba.conf_orig
                                        sed -i '/TYPE.*/a host    all     all     '"$tcipserv"'/32     md5' /var/lib/pgsql/11/data/pg_hba.conf
										sed -i 's/ident/md5/g' /var/lib/pgsql/11/data/pg_hba.conf
										sed -i 's/peer/md5/g' /var/lib/pgsql/11/data/pg_hba.conf
										sed -i 's/#synchronous_commit.*/synchronous_commit = off' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/#listen_addresses.*/listen_addresses = '"$ipserv"'' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/#work_mem.*/work_mem = 32MB' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/#effective_cache_size.*/effective_cache_size = '"$psqlmem"'GB' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/shared_buffers.*/shared_buffers = '"$psqlcache"'GB' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/max_parallel_workers =.*/max_parallel_workers = '"$cpucore2"'' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/max_worker_processes =.*/max_worker_processes = '"$cpucore2"'' /var/lib/pgsql/11/data/postgresql.conf
										sed -i 's/max_parallel_workers_per_gather =.*/max_parallel_workers_per_gather = 3' /var/lib/pgsql/11/data/postgresql.conf
										systemctl restart postgresql-11
fi
}


function createdbpsql () {
read -p "Do you want to create the Threatconnect Database ? [yes/no] : "  psqlcreate

if [ -z "$psqlcreate" ] ;  then
                printf "\nAborting Database creation\n"
        else
                sudo -u postgres psql -f ./psql/create.sql
				echo "tcuser password is : Password1!"
				pause
				sudo -u postgres psql -U tcuser -d threatconnect -f ./psql/ThreatConnect-6.1.0.sql
                fi
}

function esinst () {
				clear
				echo "INSTALL JAVA 11 FIRST"
				pause
                read -p "Do you want to download the Elasticsearch RPM ? [yes/no] : "  esdown
                if [ $esdown == 'yes' ] ; then
                                                espwd=$(pwd)
												yum -y install wget
                                                wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.7.1-x86_64.rpm
                                                rpm -ivh elasticsearch-7.7.1-x86_64.rpm
                                                sed -i 's/#cluster.name.*/cluster.name: elasticTsearch/' /etc/elasticsearch/elasticsearch.yml
												ipserv=$(ifconfig eth0 | awk 'NR==2 {print $2}')
												sed -i 's/#network.host.*/network.host: '"$ipserv"'/' /etc/elasticsearch/elasticsearch.yml
												sed -i '/network.host.*/a http.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
												sed -i '/http.host.*/a transport.host: '"$ipserv"'' /etc/elasticsearch/elasticsearch.yml
												sed -i 's/#action.destruc.*/action.destructive_requires_name: true/' /etc/elasticsearch/elasticsearch.yml
												echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
												
                else
                                                read -p "Where is located your Elasticsearch Archive ? [PATH] : "  esinpath
                                                cd $esinpath
                                                rpm -ivh elasticsearch-7.7.1-x86_64.rpm
                                                sed -i 's/#cluster.name.*/cluster.name: elasticTsearch/' /etc/elasticsearch/elasticsearch.yml
												ipserv=$(ifconfig eth0 | awk 'NR==2 {print $2}')
												sed -i 's/network.host.*/network.host: '"$ipserv"'/' /etc/elasticsearch/elasticsearch.yml
												sed -i '/network.host.*/a http.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
												sed -i '/http.host.*/a transport.host: '"$ipserv"'' /etc/elasticsearch/elasticsearch.yml
												sed -i 's/#action.destruc.*/action.destructive_requires_name: true/' /etc/elasticsearch/elasticsearch.yml
												echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
                fi
}


function esplugin () {
                read -p "Do you want to install the plugin with your internet connection ? [yes/no] : "  esdown
                if [ $esdown == 'yes' ] ; then
												cd /usr/share/elasticsearch/bin/
												./elasticsearch-plugin install ingest-attachment
                else
                                                read -p "Where is located the Elastic plugin ? [/PATH] : "  esplugpath
                                                cd /usr/share/elasticsearch/bin/
												./elasticsearch-plugin install file:/$esplugpath/ingest-attachment-7.7.1.zip
                fi
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
        somaxconntcok=$(echo "$(tput setaf 1) $somaxconntc $(tput sgr0)")
else
        somaxconntcok=$(echo "$(tput setaf 2) $somaxconntc $(tput sgr0)")
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
        tcrunncheckok=$(echo "$(tput setaf 2) Running $(tput sgr0)")
 else
	tcrunncheckok=$(echo "$(tput setaf 1) Not Running $(tput sgr0)")
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
                2)      Python ;;
                3)      installTcex ;;
                4)  	installJava ;;
                5)      installRedis5 ;;
                6)      installtcenv ;;
                7) 		fixtime ;;
                8)  	installserv ;;
                9)  	mysqlsetup ;;
                10)  	mysqlcustom2 ;;
                11) 	createdb ;;
				12)		psqlsetup ;;
				13)		psqlcustom2 ;;
				14)		createdbpsql ;;
				15)     esinst;;
                16)     esplugin;;
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
