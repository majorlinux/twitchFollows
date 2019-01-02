#!/bin/bash

FOLLOWCOUNT="$(curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users/follows?from_id=37047880' | jq .total)"


((n = $FOLLOWCOUNT / 100))
((h = $n /2))


COUNTER=0
LIMIT=0

echo GENERATING LIST

curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users/follows?from_id=37047880&first=100' | jq -r '.data[].to_id' | tee twitchid.txt > /dev/null

page="$(curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users/follows?from_id=37047880&first=100' | jq -r '.pagination.cursor')"


while [ $COUNTER -lt $n ]; do
	
	curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users/follows?from_id=37047880&first=100&after='$page'' | jq -r '.data[].to_id' | tee -a twitchid.txt > /dev/null
        page="$(curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users/follows?from_id=37047880&first=100&after='$page'' | jq -r '.pagination.cursor')"
	sleep 4
	#echo $page
	#echo $COUNTER
	#if [ $LIMIT -eq 10 ]
	#then
#		echo Waiting 30 seconds for API reset
#		LIMIT=0
#		sleep 30
#	fi

	let COUNTER=COUNTER+1
	let LIMIT=LIMIT+1
done

echo

echo GENERATING REPORTS
sleep 4

declare -a myarray
let i=0
while IFS=$'\n' read -r line_data; do
	myarray[i]="${line_data}"
	((++i))
done < twitchid.txt

let i=0
let LIMIT=0
let COUNTER=0
rm -rfv twitchInactive.txt
rm -rfv twitchActive.txt
while [ $COUNTER -lt $FOLLOWCOUNT ]; do
	published="$(curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/videos?user_id='${myarray[i]}'&first=1&type=archive' | jq -r '.data[].published_at')"
	if [ -z "$published" ]
	then
		curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users?id='${myarray[i]}'' | jq -r '.data[].display_name' | tee -a twitchInactive.txt
		echo i
		sleep 4
	else
		curl -s -H 'Client-ID: #####' -X GET 'https://api.twitch.tv/helix/users?id='${myarray[i]}'' | jq -r '.data[].display_name' | tee -a twitchActive.txt
		echo a
		sleep 4
	fi

#	if [ $LIMIT -eq 10 ]
#	then
#		echo Waiting 30 seconds for API reset
#		LIMIT=0
#		sleep 60
#	fi

	echo

	let LIMIT=LIMIT+1
	let i=i+1
	let COUNTER=COUNTER+1
done
