#!/bin/bash
echo -e "Please enter your username:"
echo -en "# "
read username

echo -e "Please enter your password:"
echo -en "# "
stty -echo
read password;
stty echo
echo

echo "Your username is: $username"
echo "Your password is: $password"
