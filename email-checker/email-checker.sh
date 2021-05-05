#!/bin/bash

#Author: Gareth Jones
#Github: https://github.com/DPR1604/Linux-scripts
#License: MIT

#Functions Start

Blacklist-check() {


#checks if ip is valid only really checks if the string matches is there are 4 section something like 1111.1111.1111.111 would still be valid this is something to improve in the future but for now this adds a resonable amount of error checking

echo -e "${Blue}Checking if IP is valid${NC}"

if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	
	echo -e "${Green}IP is valid continuing${NC}"

else   

	echo -e "${Red}IP is not valid${NC}"
	exit 1

fi

Rip=$(reverseip $ip) #Calls the reverseip function

echo -e "${Blue}Locating list of blacklist's${NC}" 

#Checks to see if the list of BL providors and if it doesn't exsist it will retreive it from github

if [ ! -f ./BLlist.txt ]; then 
	
	echo "${Blue}List Not Found Downloading list${NC}"
	wget -q $BLlistlink 

	if [ ! -f ./BLlist.txt ]; then

		echo -e "${Red}download failed please ensure wget is installed and access to${NC} $BLlistDL"
		exit 1

	fi

fi

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

echo -e "${White}Checked:${NC} $Checked ${Green}Not Listed:${NC} $NotListed ${Red}Listed:${NC} $Listed ${Blue}Unknown:${NC} $Unknown"
exit 0

}

reverseip () {
    
	#Reverses the ip so it can looked up correctly
    	local IFS
    	IFS=.
    	set -- $1
	echo $4.$3.$2.$1

}

domaintomx () {
	
	domainconfirm #calls the domain confirm function

	mxa=$(host $domain |grep mail | awk '{ print $7 }' ) #grabs the A name record used for MX

	if [ "$mxa" == "" ]; then

		echo -e "${Red}Domain does not have an MX record${NC}"
		exit 1
	fi

	echo "$domain uses $mxa for handling mail" #echos result
	sleep 1

	ip=$(host $mxa | awk '{ print $4 }' ) #Grabs the ip address the from the mx a record

	if [ "$ip" == "" ]; then

		echo -e "The A record used for the MX record does not resolve to an IP"
		exit 1
	fi

	echo "$mxa resolves to $ip" #prints result
	sleep 1 

}

domainconfirm () {

	#checks if the domain is a valid FQDN
		
	checkforhostcmd

	host $domain 2>&1 > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${Green}Valid domain continuing${NC}"
	else
		echo -e "${Red}Invalid domain name${NC}"
		echo -e "${Blue}This usually means the domain is not registered or is spelled incorrectly, you can check if the domain is registered here:${NC} https://whois.com/whois/$domain" 

		exit 1
	fi
}

checkfordigcmd () {

        if ! command -v dig &> /dev/null ; then

                echo -e "${Red}dig is not installed please install dig to run a spf check.${NC}"
                exit 1

        fi
	
}

checkforhostcmd () {

        if ! command -v host &> /dev/null ; then

                echo -e "${Red}host is not installed please install dig to run a spf check.${NC}"
		exit 1

        fi


}

usage () {

cat << EOF
	Example use
	
	email-checker.sh -d example.com -b
	email-checker.sh -i 1.1.1.1 -b

	-b Starts a blacklist check
	-d Declares a domain to be checked
	-h Displays this message
	-i Declares a IP to be checked
EOF


}

spfcheck () {

	if ! command -v dig &> /dev/null ; then

		echo "${Red}dig is not installed please install dig to run a spf check.${NC}"
		return [n]

	fi

	spf=$(dig txt $domain |grep spf | awk '{$1=$2=$3=$4="";print $0}' | sed -e 's/^[[:space:]]*//') #Grabs the domains spf record.
	echo -e "${Blue}Current SPF record is:${NC}$spf"

	if  echo $spf | grep -q $mxa ; then

		echo -e "${Green}SPF record includes $domain ${NC}"

	elif echo $spf | grep -q $ip ; then

		echo -e "${Green} SPF record includes $ip ${NC}" 

	else 
		echo "fail"

	fi

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
BLlistlink=https://raw.githubusercontent.com/DPR1604/Linux-scripts/master/email-checker/BLlist.txt #Defines a download link for the list of blacklists.


#Variables Emd

while getopts bhsd:i: opt
do
	case ${opt} in
		b ) 	Blacklist-check
			;;

		d )	domain=$OPTARG
			domaintomx
			;;
		i ) 
			ip=$OPTARG
			;;

		h )	usage
			;;

		s )	spfcheck
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
