#!/bin/bash
#Prepare essential dotfile directory
dotfile_dir="$HOME/.shadowmp3" #Do not put slash / at the end of this line
dotfile_api="api_key"
dotfile_saved="library"
[ ! -f "${dotfile_dir}/${dotfile_saved}" ] && touch "${dotfile_dir}/${dotfile_saved}"
mkdir -p $dotfile_dir

urlencode_query() {
  printf %s "$1" | od -An -tx1 -v -w${#1} | tr ' ' %
}
pull_from_library() {
  grep $1 ${dotfile_dir}/${dotfile_saved}
}

#TODO: is playlist_name= or is "query", or more at the same time
#TODO: if user exists after playing song, ask them if they want to save it to list
#TODO: if playlist has conflicting number of links to one saved item, notify user to resolve the conflict

#if $1 is API_KEY=..., run this, and set the API_PATH
if [ "${1%%=*}" = "API_KEY" ]; then
  API_KEY=${1#*=}
  echo $API_KEY > "${dotfile_dir}/${dotfile_api}"
  echo "Successfully entered an API key into ${dotfile_dir}/${dotfile_api}" && exit 0

elif [[ "$1" =~ = ]] && [ $# -eq 1 ]; then #Saving into library if has =
  [[ "$1" =~ (=).*\1 ]] && echo "Bad prompt, are you trying to save into library?" >&2 && exit 1   # err when multiple =
  [[ "$1" =~ \s ]] && echo "Bad prompt, consider replacing <space> into <underscore> if trying to save this item." >&2 && exit 1

  echo "$1" >> "${dotfile_dir}/${dotfile_saved}"
  echo 'Successfully saved item "$1" into library.' && exit 0

elif [[ "$1" =~ ^![\w\d]* ]] && [ $# -eq 1 ]; then #trying to pull from library
  pull="$(pull_from_library $1)"
  if [ $(echo "$pull" | wc -l) -gt 1 ]; then
    echo "You've got an unresolved conflict inside your library for item ${1}. Decide which to keep." >&2
    exit 1



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

API_KEY=$(cat "${dotfile_dir}/${dotfile_api}")
BASE_URL="https://www.googleapis.com/youtube/v3/search"
PARAMS="part=snippet&maxResults=${AMOUNT_OF_RESULTS}&q=${QUERY}&key=$API_KEY"

#Curl into YT, get json from query of video id, video title, channel name, thumbnail link.
#jq exits when response is null (-e flag)
NUMBER_OF_ITEM_ATTRIBUTES=4 #Update this correspondingly if you want more/less video attributes used
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
LINK_DESTINATION="https://www.youtube.com/watch?v=${parsed[0]}"

play_item(){
  mpv --no-video $1
}


#TODO: Make working PS3 MENU
#choose_menu() {
#}



