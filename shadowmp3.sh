#!/bin/bash
API_KEY=$(cat ~/.api_keys/YT_API_KEY)
BASE_URL="https://www.googleapis.com/youtube/v3/search"

urlencode_query() {
  printf %s "$1" | od -An -tx1 -v -w${#1} | tr ' ' %
}
QUERY=$(urlencode_query "$1")
AMOUNT_OF_RESULTS=2
PARAMS="part=snippet&maxResults=${AMOUNT_OF_RESULTS}&q=${QUERY}&key=$API_KEY"

#TODO: check if any argument is --max-amount= or is playlist_name= or is "query", or more at the same time

#Curl into YT, get json from query of video id, video title, channel name, thumbnail link.
NUMBER_OF_ITEM_ATTRIBUTES=4
response=$(\
  curl -s "$BASE_URL?${PARAMS}" |
  jq '.items[] | select(.id.kind == "youtube#video") | [.id.videoId, .snippet.title, .snippet.channelTitle, .snippet.thumbnails.default.url]'
)

parse_response() {
  #Decode html entities, parse into bash array
  response=${response//[/} #Remove javascript type brackets
  response=${response//]/} #End bracket is next video.
  response=${response//&amp;/&}
  response=${response//&lt;/<}
  response=${response//&gt;/>}
  response=${response//&quot;/}
  response=${response//,/}
  echo "(${response})" #Transform into makeshift bash array.
  #But delcare it only as array inside global scope, else, spooki (!!!)
}
declare -a parsed=$(parse_response) #Declare makeshift array into a proper bash one.
echo ${parsed[@]} #See? WORKS!!!!!
mpv --no-video "https://www.youtube.com/watch?v=${parsed[0]}"

#TODO: Make working PS3 MENU
#choose_menu() {
#}



