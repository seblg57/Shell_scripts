#!/bin/bash
#
# Secure SSH on a linux server to avoid brute force
# Install epel release and fail2ban
# Change SSH ports
# Restart SSH
# Config F2B
#
#######################################################
#################		SEBUX      ####################
#######################################################
#
#
yum -y install epel-release
yum -y install fail2ban
echo 'Port 60333' >> /etc/ssh/sshd_config
service sshd restart
echo '[DEFAULT]
bantime = 36000000000000000

findtime = 6
maxretry = 1

ignoreip = 127.0.0.1/8 [YOUR ADDRESS]

destemail = yourmail@protonmail.com
sender = postmaster@email.net
sendername = Fail2Ban
mta = sendmail

action = %(action_mwl)s

[sshd]
enabled = true' | tee /etc/fail2ban/jail.local
systemctl enable fail2ban
service fail2ban restart
service firewalld start
firewall-cmd --permanent --zone=public --add-port=60333/tcp
firewall-cmd --reload
fail2ban-client status sshd
netstat -antp | grep 60333