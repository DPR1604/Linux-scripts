#!/bin/bash

# author :Gareth Jones
# github :https://github.com/DPR1604

countupdates=$(/usr/bin/dnf -q check-update |wc -l) #counts the number of updates availible via DNF
ok=5 #sets OK upper limit 
warn=$(($ok + 1))  #if number of updates is higher then "ok" script returns a warning state
warnlimit=30 #sets warning upper limit
crit=$(($warnlimit + 1)) #if number of updates is higher then "warnlimit" then script returns critical state


#the below formats a response for icinga/nagios to display in alerts depending on the type of warning, it also exits the script with the correct code.
if (($countupdates<=$ok)); then 
	echo "OK - $countupdates updates available"
	exit 0

elif (($warn<=$countupdates && $countupdates<=$warnlimit)); then 
	echo "WARNING - $countupdates updates available"
	exit 1

elif (($crit<=$countupdates)); then
	echo "CRITICAL - $countupdates updates available"
	exit 2

else
	echo "UNKOWN - $countupdates"
	exit 3

fi
