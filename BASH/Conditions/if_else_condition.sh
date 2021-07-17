#!/bin/bash

echo "Please, Enter your age: "
read age

if [ "$age" -ge 18 ]; then
	echo "You are eligible for Vote"
else
	echo "You are younger!!"
fi
