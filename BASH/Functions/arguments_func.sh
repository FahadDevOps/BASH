#!/bin/bash

func_argument(){
	echo "This is the simple value: "$1
	return 10
}

# Function Call
func_argument Mars # Mars as a Parameter
func_argument Juniper # Another Parameter


echo "The above funtion have return value is:"$?
