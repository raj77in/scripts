#!/bin/bash

prev=1

for i in $(seq 1 2000 66000)
do
	range="$prev-$i"
	xterm -title $range -e "nmap -sC -sV -p$range -oA nmap-upto${i//000}k $1" &
	prev=$i
	sleep 5
done
