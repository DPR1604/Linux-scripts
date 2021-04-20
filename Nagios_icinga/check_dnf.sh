#!/bin/bash

# author :Gareth Jones
# github :https://github.com/DPR1604

countupdates=$(/usr/bin/dnf -q check-update |wc -l) #counts the number of updates availible via DNF
ok=5 
warn=$(($ok + 1)) 
warnlimit=30 
crit=$(($warnlimit + 1))

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
