#!/bin/bash

#exec 1>/tmp/out
#From :: http://jasmeu.wordpress.com/2013/03/20/raspberry-pi-send-and-receive-gmail/
#while read line
#do
#echo $line >> /tmp/mail
#done
#echo "Total inputs are $#"
#while [[ $i -le $# ]]
#do
#eval echo "input $i :: \$$i"
#(( i++ ))
#done
expectedFrom="amit@amit-agarwal.co.in"
expectedFrom2="amit.agarwal@roamware.com"
homePC="70:71:bc:31:34:a2"

mailHelp() {
	sendMail $1 "Help - Possible Commands" "Help"
}

sendMail() {
	echo "To: "$1 > $tmpMail
	echo "From: rpi@amit-agarwal.co.in" >> $tmpMail
	echo "Subject: "$2 >> $tmpMail
	echo "Content-Type: text/html" >> $tmpMail
	echo "" >> $tmpMail
	echo $3 >> $tmpMail
	cat $tempMail >> $tmpMail
	cat $tmpMail|/usr/sbin/ssmtp  $1
}
#here we start the actual processing

rightSender=0
sender=""
tmpFile=/tmp/mailtemp
tmpMail="/var/tmp/mailtxt.txt"
tempMail="/tmp/tosend.txt"
>$tempMail
>$tmpFile
>$tmpMail

#Write the mail to tmpFile
while read line
do
	echo $line >> $tmpFile
done

grep "From:" $tmpFile | grep $expectedFrom > /dev/null
if [ $? -eq 0 ]; then
	rightSender=1
	sender=$expectedFrom
fi

grep "From:" $tmpFile | grep $expectedFrom2 > /dev/null
if [ $? -eq 0 ]; then
	rightSender=1
	sender=$expectedFrom2
fi

if [ $rightSender -eq 1 ]; then
	task=`grep "Subject:" $tmpFile`
	task=${task:9}
	task=`echo $task | tr [:upper:] [:lower:]`

	echo $task | grep "help" > /dev/null
	if [ $? -eq 0 ]; then
		mailHelp $sender
		exit
	fi
fi
while read line
do
	if [[ $line =~ ^$|^Content*:*|^charset=*|^--=* ]]; then
		continue;
	fi
	echo "LINE :: $line"
	case $task in
		get)
			cmd="wget -o /dev/null -O - $line"
		;;
		wol)
			cmd="sudo etherwake \$$line"
		;;
		*)
			cmd="$line"
		;;
	esac
	eval $cmd >> $tempMail
done < <( sed '1,/^$/ d' $tmpFile|sed '/^--$/,$ d')
sendMail $sender "Output result of command $task" "Happy Hacking"

rm $tmpFile
rm $tmpMail
rm $tempMail
