#!/bin/bash
######################################################################
# Raspberry Pi
#
# Gross Script by Dweeber (Kevin Reed) <dweeber.dweebs@gmail.com>
# V1.0 2012-09-19
#
# Use the vcgencmd to obtain the Temp of the SOC
# then calculates the F value using bc.
#
# Requires bc to be loaded. If not then
# apt-get install bc
#
######################################################################
tm=`/opt/vc/bin/vcgencmd measure_temp`
tc=`echo $tm| cut -d '=' -f2 | sed 's/..$//'`
tf=$(echo "scale=2;((9/5) * $tc) + 32" |bc)
echo temp = $tf\'F \($tc\'C\)
