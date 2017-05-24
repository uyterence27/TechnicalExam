# TERENCE JOHN TJ UY #

#!/bin/bash

TOTAL_MEMORY=$( free | grep Mem: | awk '{print $2}' )
USED_MEMORY=$( free | grep Mem: | awk '{print $3}' )
USED_PERCENTAGE=$( free | grep Mem: | awk '{print $3/$2 * 100}')
USED_PERCENTAGE=${USED_PERCENTAGE%%.*}

while getopts ":c:w:e:" option;  
	do
		case $option in
			c) critical=$OPTARG ;;
			w) warning=$OPTARG ;;
			e) email=$OPTARG ;;
			*) echo "Invalid Parameter(s)! Enter values for Critical (-c) and Warning (-w) Thresholds and Email Address (-e). Example: ./memcheck.sh -c 90 -w 80 -e host@domain.com"; exit 100
		esac
	done

if [ $# -lt 3 ]
	then
		echo "Incomplete Parameters! Enter values for Critical (-c) and Warning (-w) Thresholds and Email Address (-e). Example: ./memcheck.sh -c 90 -w 80 -e host@domain.com"
	exit 100
else
	if [[ $critical -lt $warning ]]
		then
			echo "Invalid input! Critical Threshold must be higher than Warning Threshold."
	elif [[ $critical -ge 100 || $warning -ge 100 ]]
		then 
			echo "Invalid input! Critical Threshold and Warning Threshold must be less than 100."

	else

		echo "THE TOTAL MEMORY IS $TOTAL_MEMORY KB"
		echo "THE USED MEMORY IS $USED_MEMORY KB ($USED_PERCENTAGE %)"

		CRITICAL_THRESHOLD=$(( (($critical * $TOTAL_MEMORY) / 100 ) ))
		WARNING_THRESHOLD=$(( (($warning * $TOTAL_MEMORY) / 100 ) ))
		TIME=$( date +%Y%m%d\ %H:%M )
		topProcesses=$( ps axo pid,comm,rss,%mem --sort -rss | head -n 11 )

		if [[ $USED_MEMORY -ge $CRITICAL_THRESHOLD ]]
		then
			echo "$topProcesses" | mail -s "$TIME Memory Check - STATUS: CRITICAL" $email
			echo "MEMORY USAGE STATUS: CRITICAL"
			exit 2
		elif [[ $USED_MEMORY -ge $WARNING_THRESHOLD ]]
		then
			echo "MEMORY USAGE STATUS: WARNING"
			exit 1
		elif [[ $USED_MEMORY -lt $WARNING_THRESHOLD ]]
		then
			echo "MEMORY USAGE STATUS: NORMAL"
			exit 0
		fi
	fi
fi