#!/bin/bash

if [[ -e ./check_api_valid.sh ]]; then
	source ./check_api_valid.sh
	if [ $? -eq 0]; then
		
		if [[ -z "$1" ]]; then
			read -rp "Enter search query: > "
		else
			query=$1
		fi
		
		query="${query// /+}"
		echo "$query"
		urlstring="https://www.googleapis.com/youtube/v3/search?part=snippet&q=${query}&type=video&maxResults=20&key=${YOUTUBE_API_KEY}"
		

		mpv "https://$( curl -s "${urlstring}" \
			| jq -r '.items[] | "\(.snippet.channelTitle) => \(.snippet.title) youtu.be/\(.id.videoId)"' \
			| fzf --with-nth='1..-2' +m \
			| awk '{print $NF}')"


	else
		exit 1
	fi


else
	echo "Error: 'check_api_valid.sh' script not found"
	exit 1
fi
	
