#!/bin/bash

function urlencode() {
  local input="$1"
  local output=""
  local char

  for (( i = 0; i < ${#input}; i++ )); do
    char=${input:$i:1}
    case $char in
      [a-zA-Z0-9._~\-\/]) output+=$char ;;
      *) output+="%$(printf "%02x\n" <<< "${char}"); ;;
    esac
  done
  echo "$output"
}

# Test the urlencode function
input="Hello World!"
encoded=$(urlencode "$input")
echo "Encoded: $encoded"
