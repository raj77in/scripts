#!/bin/bash -
#===============================================================================
#
#		  FILE: virsh.sh
#
#		 USAGE: ./virsh.sh
#
#   DESCRIPTION:
#
#	   OPTIONS: ---
#  REQUIREMENTS: ---
#		  BUGS: ---
#		 NOTES: ---
#		AUTHOR: http://blog.amit-agarwal.co.in
# Last modified: Wed Aug 05, 2015  04:00PM
#	   CREATED: 08/05/2015 03:29:57 PM IST
#	  REVISION:  ---
#===============================================================================

export PATH=/usr/bin:$PATH
temp=$(mktemp -d  virsh.XXXXX)
cd $temp
#---  FUNCTION  ----------------------------------------------------------------
#		  NAME:  mailheader
#   DESCRIPTION:  Mail header
#	PARAMETERS:
#	   RETURNS:
#-------------------------------------------------------------------------------



mailheader ()
{
	cat <<-EOF
	To: root
	Subject: virsh info from $(hostname -s) on $(date +x)

	EOF
}	# ----------  end of function mailheader  ----------

mailheader

echo "List of instances"
/usr/bin/virsh list  >list
while read id name state
do
	echo "Info for $name"
	virsh dominfo $name
	echo "Block device information "
	virsh domblkinfo $name vda
	virsh domblkstat $name vda
	# virsh domstats $name
	echo -ne "$name,">>stats.csv
	virsh domstats $name |awk -F'=' '{if (NF>=2) printf $2",";}' >>stats.csv
	echo >>stats.csv
done < <(sed '1,/------/ d' list|sed '/^$/d')
virsh iface-list
cat stats.csv
rm -rf  $temp
