#!/bin/bash


while true
do
	read -p "Please, enter any number (Press 5 or 7 to exit) " numb
	if [[ $numb -eq 5 || $numb -eq 7 ]]
	then
		break 
	else
		continue
	fi
done
