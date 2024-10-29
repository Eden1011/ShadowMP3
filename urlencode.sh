#!/bin/bash

function encode() {
	local out=""
	local count=0
	arg=$1

	until [ $count -eq ${#arg} ]; do
		char=${arg:count:1}
		echo $char
		case $char in
			[a-zA-Z\d._~\-\/]) 
				out+=$char
		;;
			*) 
				out+="%$(printf "%02x" <<< "${char}")"
		;;
		esac
	
		count+=1
	done
	echo "$out"
}
encode "duran duran"
