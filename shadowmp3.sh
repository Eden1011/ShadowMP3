#!/bin/bash
#Prepare essential dotfile directory
dotfile_dir="$HOME/.shadowmp3" #Do not put slash / at the end of this line
dotfile_api="api_key"
mkdir -p $dotfile_dir

urlencode_query() {
  printf %s "$1" | od -An -tx1 -v -w${#1} | tr ' ' %
}
register_script_args() {
  #if $1 is API_KEY=..., run this, and set the API_PATH
  if [ ${1%%=*} = "API_KEY" ]; then
    API_KEY=${1#*=}
    echo $API_KEY > "${dotfile_dir}/${dotfile_api}"
    echo "Successfully entered an API key into ${dotfile_dir}/${dotfile_api}" && exit 0
  elif [ $# -eq 2 ] && [[ "$2" =~ ^[0-9]+$ ]]; then
    AMOUNT_OF_RESULTS=$2
    QUERY=$(urlencode_query "$1")
  elif [ $# -eq 1 ]; then
    QUERY=$(urlencode_query "$1")
    AMOUNT_OF_RESULTS=5
  else
    echo "Error: improper amount of arguments." >&2
    exit 1
  fi
}
register_script_args $@
BASE_URL="https://www.googleapis.com/youtube/v3/search"
PARAMS="part=snippet&maxResults=${AMOUNT_OF_RESULTS}&q=${QUERY}&key=$API_KEY"

#TODO: check if any argument is --max-amount= or is playlist_name= or is "query", or more at the same time

#Curl into YT, get json from query of video id, video title, channel name, thumbnail link.
#jq exits when response is null (-e flag)
NUMBER_OF_ITEM_ATTRIBUTES=4
response=$(\
  curl -s "$BASE_URL?${PARAMS}" |
  jq -e '.items[] | select(.id.kind == "youtube#video") | [.id.videoId, .snippet.title, .snippet.channelTitle, .snippet.thumbnails.default.url]'
)
#check response status, display custom err
if [ $? -ne 0 ]; then
  echo "Error: Youtube API key is bad or no query results. Try replacing it at ${dotfile_dir}/${dotfile_api}" >&2
  exit 1
fi



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
echo ${parsed[@]}
mpv --no-video "https://www.youtube.com/watch?v=${parsed[0]}"

#TODO: Make working PS3 MENU
#choose_menu() {
#}



