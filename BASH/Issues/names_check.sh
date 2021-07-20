#!/bin/bash

# Names List: Ali, Hassa, Nadeem
read -p "Please, enter the name: " names

for name in  names; do
	if [[ $names == "Ali" || $names == "Hassan" || $names == "Nadeem" ]]; then
		echo "You enter correct name: "$names
	else
		echo "Please,Re-run and write the correct name"
	fi
done
