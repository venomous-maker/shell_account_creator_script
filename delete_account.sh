#!/bin/bash

# This script is to undo the changes made to the system when using the assignment 8
script to create user accounts, and giving them SSH access
echo “What was the username for the account you need to remove? “
read username
deluser $username
rm -r /home/$username
rm -r ./$username
