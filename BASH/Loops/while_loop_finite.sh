#!/bin/bash

count=1
echo "Counting from 1 to 10:"
while [[ $count -le 10 ]]
do
	echo -n " " $count
	((count++))
done 

echo "  All Done"
