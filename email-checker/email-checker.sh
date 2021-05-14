#!/bin/bash

#Author: Gareth Jones
#Github: https://github.com/DPR1604/Linux-scripts
#License: MIT
#version: 0.9.7

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
	
	ToCheck=$Rip.$line 						#Puts together the ip address and blacklist together to generate the dns Record to be checked

	Output=$(host $ToCheck) 					#Runs host against the generated record

	Checked=$(($Checked +1)) 					#Add's 1 to the number of checked RBL's

	if echo $Output| grep -q "$ToCheck not found" ; then 		#Checks for not found in the Output.
	
		echo -e ${Green}IP is not listed in $line${NC} 		#Output to terminal that the ip is not listed in the RBL
		NotListed=$(($NotListed + 1)) 				#Adds 1 to the number of not listed

	elif echo $Output | grep -q "$ToCheck has address" ; then 	#Checks for "has address"

		echo -e ${Red}IP is listed in $line${NC} 		#Outputs to terminal that the ip is listed.
		Listed=$(($Listed + 1)) 				#Adds 1 to the number of listed

	else								#if other two statements dont match then 

		echo -e ${Blue}Unknown result for $line${NC} 		#outputs to terminal that the result is unknown
		Unknown=$(($Unknown + 1))

	fi


done < "$BLlist"

echo -e "${White}Checked:${NC} $Checked ${Green}Not Listed:${NC} $NotListed ${Red}Listed:${NC} $Listed ${Blue}Unknown:${NC} $Unknown" 		#Outputs to the terminal the total RBLS checked the total unlisted, listed and unknown

}

checkfordigcmd () {

        if ! command -v dig &> /dev/null ; then								#checks if dig is not installed

                echo -e "${Red}dig is not installed please install dig to run a spf check.${NC}"	#Outputs to terminal that dig is not installed
                exit 1

        fi
	
}

checkforhostcmd () {

        if ! command -v host &> /dev/null ; then							#checks if host is not installed

                echo -e "${Red}host is not installed please install host to run a spf check.${NC}"	#Outputs to terminal that host is not installed
		exit 1

        fi


}

domaintomx () {
	
	domainconfirm 										#calls the domain confirm function

	mxa=$(host $domain |grep mail | awk '{ print $7 }' ) 					#grabs the A name record used for MX

	if [ "$mxa" == "" ]; then								#Checks if the A record from the MX record is blank

		echo -e "${Red}Domain does not have an MX record${NC}"				#Outputs to the terminal that the domain has an empty mx record
		exit 1
	fi

	echo "$domain uses $mxa for handling mail" 						#Outputs to terminal the mx record the domain uses for mail
	sleep 1

	ip=$(host $mxa | awk '{ print $4 }' ) 							#Grabs the ip address the from the mx a record

	if [ "$ip" == "" ]; then								#Checks if the mxa has an IP

		echo -e "The A record used for the MX record does not resolve to an IP"		#Outputs to terminal that the ip is blank
		exit 1
	fi

	echo "$mxa resolves to $ip" 								#Outputs the ip the mxa resolves to
	sleep 1 

}

domainconfirm () {

	#checks if the domain is a valid FQDN
		
	checkforhostcmd										#Calls the checkforhostcmd function

	host $domain 2>&1 > /dev/null								#runs a host command with outout to dev/null
	if [ $? -eq 0 ]										#checks if if the output is 0
	then
		echo -e "${Green}Valid domain continuing${NC}"					#outputs to terminal that domain is valid/registered
	else
		echo -e "${Red}Invalid domain name${NC}"					#outputs to terminal that domain is not valid
		echo -e "${Blue}This usually means the domain is not registered or is spelled incorrectly, you can check if the domain is registered here:${NC} https://whois.com/whois/$domain" 

		exit 1
	fi

}

Portcheck () {

	for i in 25 587 143 993 110 995 
	do

		nc -vz -w10 mail.valhallaonline.info $i |& grep -q Connected
		if [ $? -eq 0 ]; then

			echo -e "${Green}$i is open ${NC}"
			eval stat$i="Open"

		elif [ $? -eq 1 ]; then
			
			echo -e "${Red}$i is closed ${NC}"
			eval stat$i="closed"

		else	

			echo -e "${Blue}unknown state when checking port $i please manually check with:${NC} nc -vz -w10 $ip $i"

		fi
	done

	echo $stat25
	echo $stat587
	echo $stat143
	echo $stat993
	echo $stat110
	echo $stat995

}

reverseip () {
    
	#Reverses the ip so it can looked up correctly
    	local IFS
    	IFS=.
    	set -- $1
	echo $4.$3.$2.$1

}

spfcheck () {

	checkfordigcmd

	spf=$(dig txt $domain |grep spf | awk '{$1=$2=$3=$4="";print $0}' | sed -e 's/^[[:space:]]*//') #Grabs the domains spf record.
	echo -e "${Blue}Current SPF record is:${NC}$spf"

	if  echo $spf | grep -q $mxa ; then

		echo -e "${Green}SPF record includes $mxa ${NC}"

	elif echo $spf | grep -q $ip ; then

		echo -e "${Green} SPF record includes $ip ${NC}" 

	else 
		echo "fail"

	fi

}

summary () {

	printf "+--------------------DNS-------------------+--------------------------------------------------------------+\n"
	printf "| %40s | %60s |\n"
	printf "| %40s | %60s |\n" "Domains current MX record points to" $mxa 
       	printf "| %40s | %60s |\n" "$mxa resolves to IP" $ip 
	printf "| %40s | %60s |\n"
	printf "+--------------------SPF-------------------+--------------------------------------------------------------+\n"
	printf "| %40s | %60s |\n"
	printf "| %40s | %60s |\n" "Current spf record" "$spf"
	printf "| %40s | %60s |\n" "Recommended SPF record" "v=spf1 a:$mxa ip4:$ip ~all"
	printf "| %40s | %60s |\n"
	printf "+----------------BL checks-----------------+--------------------------------------------------------------+\n"
	printf "| %40s | %60s |\n"
	printf "| ${White}%40s${NC} | %60d |\n" "Checked" $Checked
	printf "${Green}"
	printf "| %40s | %60d |\n" "Not listed" $NotListed
	printf "${Red}"
	printf "| %40s | %60d |\n" "Listed" $Listed
	printf "${Blue}"
	printf "| %40s | %60d |\n" "Unknown" $Unknown
	printf "${NC}"
	printf "| %40s | %60s |\n"
	printf "+-------------------Ports------------------+--------------------------------------------------------------+\n"
	printf "| %40s | %60s |\n"
	printf "| %40s | %60s |\n" "SMTP (25)"   
	printf "+------------------------------------------+--------------------------------------------------------------+\n" 

}

usage () {

#outputs how to use the scripts

cat << EOF
	Example use
	
	email-checker.sh -d example.com -b
	email-checker.sh -i 1.1.1.1 -b

	-b Starts a blacklist check
	-d Declares a domain to be checked
	-h Displays this message
	-i Declares a IP to be checked
	-s Start an spf check
EOF


}

#Variables Start
ip="" 													#clears the ip variable
BLlist="./BLlist.txt" 											#declares the list of blacklists
Checked=0 												#resets variable counter to 0
Listed=0 												#resets variable counter to 0
NotListed=0 												#resets variable counter to 0
Unknown=0 												#resets variable counter to 0
Green='\033[1;32m' 											#defines green colour
White='\033[1;37m'											#defines white colour
Red='\033[0;31m'											#defines the red colour
Blue='\033[1;34m'											#defines the blue colour
NC='\033[0m' 												#resets the text colour
BLlistlink=https://raw.githubusercontent.com/DPR1604/Linux-scripts/master/email-checker/BLlist.txt 	#Defines a download link for the list of blacklists.

#Variables Emd

while getopts abhspd:i: opt
do
	case ${opt} in
		a )	Blacklist-check
			spfcheck
			summary
			;;

		b ) 	Blacklist-check
			;;

		d )	domain=$OPTARG
			domaintomx
			;;

		h )     usage
                        ;;
		
		i ) 
			ip=$OPTARG
			;;

		p )	Portcheck
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
