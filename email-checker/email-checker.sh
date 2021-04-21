#!/bin/bash

#Author: Gareth Jones
#Github: https://github.com/DPR1604/Linux-scripts
#License: MIT

#Functions Start

Blacklist-check() {

Rip=$(reverseip $ip) #Calls the reverseip function

# Checks against the blacklists for the ip
while IFS= read -r line; do
	
	ToCheck=$Rip.$line

	Output=$(host $ToCheck)

	#echo $Output
	Checked=$(($Checked +1))

	if echo $Output| grep -q "$ToCheck not found" ; then
	
		echo -e ${Green}IP is not listed in $line${NC}
		NotListed=$(($NotListed + 1))

	elif echo $Output | grep -q "$ToCheck has address" ; then

		echo -e ${Red}IP is listed in $line${NC}
		Listed=$(($Listed + 1))

	else	

		echo -e ${Blue}Unknown result for $line${NC}
		Unknown=$(($Unknown + 1))

	fi


done < "$BLlist"

echo -e ${White}Checked:${NC} $Checked ${Green}Not Listed:${NC} $NotListed ${Red}Listed:${NC} $Listed ${Blue}Unknown:${NC} $Unknown

exit 0

}

reverseip () {
    
	#Reverses the ip so it can looked up correctly
    	local IFS
    	IFS=.
    	set -- $1
	echo $4.$3.$2.$1

}

#Variables Start
ip="" #clears the ip variable
BLlist="./BLlist.txt" #declares the list of blacklists
Checked=0 #resets variable counter to 0
Listed=0 #resets variable counter to 0
NotListed=0 #resets variable counter to 0
Unknown=0 #resets variable counter to 0
Green='\033[1;32m' #defines green colour
White='\033[1;37m'
Red='\033[0;31m'
Blue='\033[1;34m'
NC='\033[0m' #resets the text colour

#Variables Emd

while getopts bi: opt
do
	case ${opt} in
		b ) 	Blacklist-check
			;;
		i ) 
			ip=$OPTARG
			;;
	    	\? )
			echo "Invalid option: $OPTARG" 1>&2
			;;
		: )
			echo "Invalid option: $OPTARG requires an argument" 1>&2
			;;
	esac
done
shift $((OPTIND -1))

exit 0
