#!/bin/bash -
#===============================================================================
#
#          FILE: update-rfc.sh
#
#         USAGE: ./update-rfc.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@roamware.com
#  ORGANIZATION: Roamware
# Last modified: Thu May 28, 2015  12:49PM
#       CREATED: 04/23/2013 05:51:06 PM IST
#      REVISION:  ---
#===============================================================================


export sub="$(/usr/bin/basename $0) Update RFC"
/home/roamware/bin/mailheader.sh

getFile ()
{
    filename=${1##*/}
    cp $filename{,.backup}
    wget -o /dev/null -N  $1
    echo "Downloaded file $filename"
}	# ----------  end of function getFile  ----------
DATADIR=/home/roamware/repo/RFC/
echo "Workign directory is $DATADIR"
cd $DATADIR


#### wget http://www.w3.org/Protocols/rfc2616/rfc2html.pl

getFile ftp://ftp.rfc-editor.org/in-notes/rfc-index.txt
getFile ftp://ftp.rfc-editor.org/in-notes/rfc-index.xml
getFile ftp://ftp.rfc-editor.org/in-notes/tar/RFC-all.tar.gz
tar xf RFC-all.tar.gz
echo "Extracted RFC-all.tar.gz"
getFile http://www.iana.org/assignments/protocol-numbers/protocol-numbers.txt
getFile ftp://www.iana.org/assignments/port-numbers
cat <<EOF >index.html
<html>
<head>
<title>RFC Index -autogenerated</title>
</head>
<body>
<h3>AutoGenerated on $(date) - RFC Index</h3>
Amit Agarwals script
EOF
# cat rfc-index.txt|sed 's=\(^[0-9]\{4\}\)=<a href\="rfc\1.txt">\1</a>=g' >> index.html

#awk '/^[0-9]/ {print "<a href=rfc"$1+0".txt>"$1"</a>"; for(i=2; i<=NF; i++) printf "%s"  $i }' rfc-index.txt
#awk 'if (/^[0-9]/) {print "<BR><a href=rfc"$1+0".txt>"$1"</a>"; for(i=2; i<=NF; i++) printf ("%s ", $i); } else {print "<pre>"$0"</pre"}' rfc-index.txt >> index.html

echo '<pre>' >> index.html;
awk '{if ($0 ~ /^[0-9]/) {printf ("<a href=rfc2html/rfc2html.php?in=%d>%d</a>\t",$1+0, $1); for(i=2; i<=NF; i++) printf ("%s ", $i);printf("\n"); } else {print $0;}}' rfc-index.txt >> index.html

echo "</body></html>" >> index.html


cat <<EOF >>/dev/null
for i in *txt
do
    perl rfc2html.pl $i > ${i//txt/html}
done
EOF
