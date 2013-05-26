#!/bin/bash -
#===============================================================================
#
#          FILE: copy.sh
#
#         USAGE: ./copy.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Amit Agarwal (aka), amit.agarwal@roamware.com
#  ORGANIZATION: Roamware
# Last modified: Sun May 26, 2013  16:13PM
#       CREATED: 05/25/2013 06:17:32 PM IST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

rsync -avrL -e ssh pi:dev/ .
