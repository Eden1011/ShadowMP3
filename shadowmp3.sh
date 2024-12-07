#!/bin/bash
#Prepare essential dotfile directory
dotfile_dir="$HOME/.shadowmp3" #Do not put slash a trailing '/' at the end of this line.
dotfile_api="api_key"
dotfile_saved="library"
[ ! -f "${dotfile_dir}/${dotfile_saved}" ] && touch "${dotfile_dir}/${dotfile_saved}"
mkdir -p "$dotfile_dir"

urlencode_query() {
  printf %s "$1" | od -An -tx1 -v -w${#1} | tr ' ' %
}
#Change this accordingly to your preference. By default, only audio is played.
play_item(){
  mpv --no-video --loop-file=yes "$1" || exit; exit # Exit if error or exit if EOF.
  trap exit SIGINT # Override previous trap, because played item was already saved.
}

# If agrument contains an equals sign, and the preceding text is API_KEY, save the rest into file.
if [ "${1%%=*}" = "API_KEY" ]; then
  API_KEY=${1#*=}
  echo $API_KEY > "${dotfile_dir}/${dotfile_api}"
  echo "Successfully entered an API key into ${dotfile_dir}/${dotfile_api}." && exit 0

# If argument does not contain spaces, and has an equals sign, then will be saved into library.
elif [[ "$1" =~ ^([^\ ])+=([^\ ])+ ]] && [ $# -eq 1 ]; then
  echo "$1" >> "${dotfile_dir}/${dotfile_saved}"
  echo "Successfully saved item $1 into library: ${dotfile_dir}/${dotfile_saved}." && exit 0

# If argument does the above, but does not contain an equals sign, then is being pulled from library.
elif [[ "$1" =~ ^@([^\ ])+ ]] && [ $# -eq 1 ]; then
  item=${1#*@}
  pulled=$(grep -w "$item" "${dotfile_dir}/${dotfile_saved}")
  num_of_lines=$(echo "$pulled" | grep -c '^[^ ]') # Counts number of non-blank lines
  if [ "$num_of_lines" -eq 1 ]; then
    link=${pulled#*=}
    play_item "$link"
  elif [ "$num_of_lines" -eq 0 ]; then
    echo "No matches found for item ${1}." && exit
  else
    echo "You've got an unresolved conflict inside your library for item ${1}. Decide which to keep." >&2
    exit 1
  fi

elif [ $# -eq 2 ] && [[ "$2" =~ ^[0-9]+$ ]]; then # If an amount is specified
  AMOUNT_OF_RESULTS=$2
  QUERY=$(urlencode_query "$1")
elif [ $# -eq 1 ]; then                           # If not -> put it as 5
  QUERY=$(urlencode_query "$1")
  AMOUNT_OF_RESULTS=5
else
  echo "Error: improper amount of arguments." >&2
  exit 1
fi

# Retrieve api key from dotfile
API_KEY=$(cat "${dotfile_dir}/${dotfile_api}")
BASE_URL="https://www.googleapis.com/youtube/v3/search"
PARAMS="part=snippet&maxResults=${AMOUNT_OF_RESULTS}&q=${QUERY}&key=$API_KEY"

# Curl into YT, get json from query of video id, video title, channel name, thumbnail link.
# Command jq will exit when the response is null (-e flag).
NUMBER_OF_ITEM_ATTRIBUTES=4 # Update this variable if you want more/less video attributes to be pulled.
response=$(\
  curl -s "$BASE_URL?${PARAMS}" |
  jq -e '.items[] | select(.id.kind == "youtube#video") | [.id.videoId, .snippet.title, .snippet.channelTitle, .snippet.thumbnails.default.url]'
)
# Check response status, display custom err.
if [ $? -ne 0 ]; then
  echo "Error: Youtube API key is bad or no query results. Try replacing it at ${dotfile_dir}/${dotfile_api}" >&2
  exit 1
fi

parse_response() {
  # Decode html entities, parse into bash array
  response=${response//[/} # Remove javascript type brackets
  response=${response//]/} # End bracket is next video.
  response=${response//&amp;/&}
  response=${response//&lt;/<}
  response=${response//&gt;/>}
  response=${response//&quot;/}
  response=${response//,/}
  echo "(${response})" # Transform into makeshift bash array.
  # But delcare it only as an array inside global scope.
}

declare -a parsed=$(parse_response) #Declare makeshift array into a proper bash one.
LINK_DESTINATION="https://www.youtube.com/watch?v="

choose_menu() {
  clear
  PS3="Enter your choice (1..$((${#parsed[@]}/NUMBER_OF_ITEM_ATTRIBUTES+1))): > "
  local titles=()
  for ((i=1; i<${#parsed[@]}; i+=NUMBER_OF_ITEM_ATTRIBUTES)); do
    channel_name="${parsed[i+1]}"
    title="${parsed[i]}"
    titles+=("$channel_name -- \"$title\"")
  done

  echo "Please pick from result(s):"
  select choice in "${titles[@]}" "Quit"; do
    if [[ "$REPLY" -eq  $(( ${#titles[@]}+1)) ]]; then
      echo "Exiting..." && exit
    fi

    if [[ "$REPLY" -gt 0 && "${REPLY}" -le ${#titles[@]} ]]; then
      local index_Id=$(( (REPLY-1) * NUMBER_OF_ITEM_ATTRIBUTES ))
      local thumbnail_Id=$(( (REPLY-1) * NUMBER_OF_ITEM_ATTRIBUTES + NUMBER_OF_ITEM_ATTRIBUTES - 1))
      curl -s "${parsed[thumbnail_Id]}" | catimg - -w 50 -r 0.7 # Display thumbnail
      trap "ask_save ${parsed[index_Id]}" SIGINT # Override interruption signal to ask user about saving.
      play_item "${LINK_DESTINATION}${parsed[index_Id]}"
      exit
    else
      echo "Invalid selection"
    fi
  done
}

ask_save() {
  until [[ "$answer" == "y" || "$answer" == "n" || "$answer" == "q" ]]; do
    read -rp "Would you like to save this track to library? (y/n|q): > " answer
  done
  if [[ "$answer" == "y" ]]; then
    read -rp "What name would you like this track to be saved under? (avoid spaces): > " save_as_name
    echo "${save_as_name}=${LINK_DESTINATION}${1}" >> "${dotfile_dir}/${dotfile_saved}"
    echo "Successfully saved item ${save_as_name}."
  else
    echo "Exiting..." && exit
  fi
}

choose_menu


