#!/bin/bash
#
# Connect to HiveOS API FARM
# 2FA Enable
# 
# 
#  _____________________  _     _ _     _ 
# / _____|_______|____  \(_)   (_|_)   (_)
#( (____  _____   ____)  )_     _ \ \__//  
# \____ \|  ___) |  __  (| |   | | |   |  
# _____) ) |_____| |__)  ) |___| |/ / \ \ 
#(______/|_______)______/ \_____/|_|   |_|
#   
#
#######################################################
#################		SEBUX      ####################
#######################################################

baseUrl='https://api2.hiveos.farm/api/v2'

read -p "Login : "  login
read -p "Password : "  password
read -p "Token : " code
# 1. Login
response=`curl -s -w "\n%{http_code}" \
         -H "Content-Type: application/json" \
         -H "X-Security-Code: $code" \
         -X POST \
         -d "{\"login\":\"$login\",\"password\":\"$password\"}" \
         "$baseUrl/auth/login"`
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

# Extract access token
accessToken=`echo "$response" | jq --raw-output '.access_token'`

# 2. Get farms
response=`curl -s -w "\n%{http_code}" \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $accessToken" \
         "$baseUrl/farms"`
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
statusCode=`echo "$response" | tail -1`
response=`echo "$response" | sed '$d'`
[[ $statusCode -lt 200 || $statusCode -ge 300 ]] && { echo "$response" | jq 1>&2; } && exit 1

# Display farms
echo "$response" | jq