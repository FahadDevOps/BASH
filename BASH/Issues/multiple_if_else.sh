#!/bin/bash

# Multiple if-else

echo "Please, enter the Percentage Number between 1 to 100:"
read numb

if [[ $numb -ge 80 && $numb -lt 100 ]]; then
	echo "You are awarded Grade A"
elif [[ $numb -ge 60 && $numb -lt 80 ]]; then
	echo "You are awarded Grade B"
elif [[ $numb -ge 40 && $numb -lt 60 ]]; then
	echo "You are awarded Grade C"
elif [[ $numb -ge 20 && $numb -lt 40 ]]; then
	echo "You are awarded Grade D"
elif [[ $numb -ge 1 && $numb -lt 20 ]]; then
	echo "You are Fail, Try Again !!!"
else
	echo "Please, Enter valid number"
fi
