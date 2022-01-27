#!/bin/bash
# Require bind-utils on Centos/RH/Rocky
# yum install bind-utils
#
#######################################################
#################		SEBUX      ####################
#######################################################
set -eu -o pipefail
domain="${1:-NULL}"
 
# fail safe i.e. if no $1 passed to the script, die with an error
[ "$domain" == "NULL" ] && { echo "Usage: $0 domain-name"; exit 1; }
 
# make sure dig installed else die
if ! type -a dig &>/dev/null 
then
	echo "Error: $0 - dig command not found."
	exit 2
fi
 
# repeat given char 90 times
repeat(){
	for i in {1..90}; do echo -n "$1"; done
}
 
# get first ns for domain
# remove everything except domain.com 
str="${domain%.*.*}"
domain="${domain/$str./}"
 
ns="$(dig +nocmd +noall +answer ns "${domain}" | head -1 | awk '{ print $5}')"
 
# now print ttl for a, aaaa, and mx
repeat '-'
echo -e "\nDomain\t\t\tTTL\tIN\tRecord\tAnswer"
repeat '-'
echo 
 
for i in a aaaa mx
do   
	dig +nocmd +noall +answer +ttlunits "${i}" "${domain}" "@${ns}"
done