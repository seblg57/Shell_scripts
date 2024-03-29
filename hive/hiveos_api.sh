#!/bin/bash
#######################################################
#################		SEBUX      ####################
#######################################################
#
#
# Stats for hiveos with apiv2
# 
#  _____________________  _     _ _     _ 
# / _____|_______|____  \(_)   (_|_)   (_)
#( (____  _____   ____)  )_     _ \ \__//  
# \____ \|  ___) |  __  (| |   | | |   |  
# _____) ) |_____| |__)  ) |___| |/ / \ \ 
#(______/|_______)______/ \_____/|_|   |_|
#
if [ -z $1 ]; then
	echo "usage: ./hive_api function_name parameters"
	echo "function: all_workers_stat | worker_stat | fs_list | oc_list | fs_apply FS_ID | oc_apply OC_ID"
	exit
fi


baseUrl='https://api2.hiveos.farm/api/v2'



read -p "Login : "  login
read -p "Password : "  you_passwd
read -p "Farm ID : "  FARM_ID
read -p "RIG ID : "  RIG_ID

TOKEN="/opt/tok"
accessToken=""


function login {
	response=`curl -s -w "\n%{http_code}" \
		-H "Content-Type: application/json" \
		-X POST \
		-d "{\"login\":\"$login\",\"password\":\"$password\",\"remember\": true}" \
		"$baseUrl/auth/login"`
	[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
	statusCode=`echo "$response" | tail -1`
	response=`echo "$response" | sed '$d'`
#	[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1
read -p "Press enter to stop the agent and the server"
	# Extract access token
#	accessToken=`echo "$response" | jq --raw-output '.access_token'`
	echo "accessToken=\"$accessToken\"" > $TOKEN
}

function check_token {
	response=`curl -s -w "\n%{http_code}" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $accessToken" \
		"$baseUrl/auth/check"`
	[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
	statusCode=`echo "$response" | tail -1`
	[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1
	if [ $statusCode -eq 204 ]; then
		echo true
	else
		echo false
	fi
}


function all_workers_stat {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 "$baseUrl/farms/$FARM_ID/workers"`
	 
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

echo "$response"
}


function worker_stat {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 "$baseUrl/farms/$FARM_ID/workers/$RIG_ID"`
	 
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

echo "$response"
}


function fs_list {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 "$baseUrl/farms/$FARM_ID/fs"`
	 


echo "$response"
}

function oc_list {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 "$baseUrl/farms/$FARM_ID/oc"`
	 


echo "$response"
}


function fs_apply {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 -X PATCH \
	 -d "{\"fs_id\": $1}" \
	 "$baseUrl/farms/$FARM_ID/workers/$RIG_ID"`
	 
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

echo "$response"
}


function oc_apply {
response=`curl -s -w "\n%{http_code}" \
	 -H "Content-Type: application/json" \
	 -H "Authorization: Bearer $accessToken" \
	 -X PATCH \
	 -d "{\"oc_id\": $1}" \
	 "$baseUrl/farms/$FARM_ID/workers/$RIG_ID"`
	 
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

echo "$response"
}


[ -f $TOKEN ] && source $TOKEN
[ -z $accessToken ] && login

[ ! $(check_token) ] && login

echo $($1 $2) | jq .
exit 0