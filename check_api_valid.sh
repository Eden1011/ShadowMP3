#!/bin/bash

if [[ -z $YOUTUBE_API_KEY ]]; then
	echo "Error: please declare 'YOUTUBE_API_KEY' environment variable to continue."
        exit 1 
else
	exit 0
fi

