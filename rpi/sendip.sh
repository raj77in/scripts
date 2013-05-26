#!/bin/bash -
#===============================================================================
#
#          FILE: sendip.sh
#
#         USAGE: ./sendip.sh
#
#   DESCRIPTION: This script will email the IP address to desired email.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@roamware.com
#  ORGANIZATION: Roamware
# Last modified: Sun May 26, 2013  18:11PM
#       CREATED: 05/26/2013 03:15:26 PM IST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
recepient="amit.agarwal@amit-agarwal.co.in"
sender=ipaddress@amit-agarwal.co.in
tempf="/home/pi/dev/"

ip=$(ip addr show|grep "inet "|grep -v 127.0.0. | awk '{print $2}'|tr '\n' ','|sed 's/,$//')
ip=$(ip addr|sed -n "s/^[[:space:]]\+inet \([0-9.]\+\).*/\1/p"| grep -v 127.0.0.1|head -1)
if [[ $(date +%M) == "00" ]]
then
	extip=$(curl -s http://amit-agarwal.com/mystuff/getip_txt.php |tail -1)
	if [[ $(cat $tempf/externalip) != $extip ]]
	then
		echo "External IP is changed, call inadyn"
		echo $extip >$tempf/externalip
		/usr/sbin/inadyn
	fi
fi
if [[ $(cat $tempf/localip) != $ip ]]
then
	echo $ip >$tempf/localip
fi
if [[ $(cat $tempf/localip) != $ip || $(cat $tempf/externalip) != $extip ]]
then
	if [[ $ip != "192.168.2.106" ]]
	then
		echo "IP addresses are $ip"
		echo "To: $recepient
		From: $sender
		Subject: IP address of $(hostname -s) is $ip

		Your external IP is $extip.

		$(ip addr show)"|/usr/sbin/ssmtp $recepient
	else
		echo "IP address has not changed."
	fi
fi
