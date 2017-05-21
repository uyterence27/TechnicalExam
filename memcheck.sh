



####    TERENCE JOHN TJ BORDEOS UY    ######

#!bin/bash

TOTAL_MEMORY=$( free | grep Mem: | awk '{print $2}' )
USED_MEMORY=$( free | grep Mem: | awk '{print $3}' )
USED_PERCENTAGE=$( free | grep Mem: | awk '{print $3/$2 * 100}')
USED_PERCENTAGE=${USED_PERCENTAGE%%.*}

echo "THE TOTAL MEMORY IS $TOTAL_MEMORY KB"
echo "THE USED MEMORY IS $USED_MEMORY KB ($USED_PERCENTAGE %)"


while getopts ":c:w:e:" option;  
do
	case $option in
		c) critical=$OPTARG ;;
		w) warning=$OPTARG ;;
		e) email=$OPTARG ;;
	esac
done

if [ $# -lt 3]
then
	clear;
	echo -e  "Incomplete Parameters! Enter values for Critical (-c) and Warning (-w) Thresholds and Email Address (-e). Example: ./memory_check -c 90 -w 80 -e test@domain.com\n\n"
elif [ $critical -lt $warning ]
then
	clear;
	echo "Invalid input! Critical Threshold must be higher than Warning Threshold."
elif [[ $critical -ge 100 || $warning -ge 100 ]]
then 
	clear;
	echo "Invalid input! Critical Threshold and Warning Threshold must be less than 100."

else
	CRITICAL_THRESHOLD=$(($critical*$TOTAL_MEMORY/100))
	WARNING_THRESHOLD=$(($warning*$TOTAL_MEMORY/100))
	TIME=$( date +%Y%m%d\ %H:%M )
	topProcesses=$( ps axo pid,comm,rss,%mem --sort -rss | head -n 11 )

	if [[ $USED_MEMORY -ge $CRITICAL_THRESHOLD ]]
	then
		echo "$topProcesses" | mail -s "$TIME memory check - critical" $email
		exit 2
	elif [[ $USED_MEMORY -ge $WARNING_THRESHOLD ]]
	then
		exit 1
	elif [[ $USED_MEMORY -lt $WARNING_THRESHOLD ]]
	then
		exit 0
	fi
fi




