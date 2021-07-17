#!/bin/bash

# Variable Scope(Local and Global Variable)

var_change()
{
	local var1="local1" # Local Varaible.
	echo 'Inside function var1 is:' $var1  'and var2 is: ' $var2
}

var1='global 1'	#By default it's considered as Global variable.
var2='global 2'

echo 'Variables before function call is:' $var1 'and' $var2

var_change

echo 'Variables after function call is:' $var1 'and' $var2
