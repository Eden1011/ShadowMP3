#!/bin/bash

API_KEY=$(cat ~/.api_keys/YT_API_KEY)

API_ENDPOINT="https://www.googleapis.com/youtube/v3/search"

QUERY=$1

PARAMS="part=snippet&maxResults=10&q=${QUERY}&key=$API_KEY"

curl -s -X GET "$API_ENDPOINT?${PARAMS}" | \
jq '.items[] | select(.id.kind == "youtube#video") | [.id.videoId, .snippet.title]'
