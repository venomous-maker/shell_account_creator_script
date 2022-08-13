#!/usr/bin/bash
echo "This script will create a new user account on this system. The script will
also attempt to generate the relevant RSA encryption files and configure the
account for SSH login. "
# Step 1 : Get Information
################################################################################
echo "Please provide the following information for the new user. "
echo "First Name: "
read FirstName
echo "Lastname: "
read LastName
echo "Email address: "
read email
echo "username: "
read username
adduser --disabled-password --geco $FirstName,LastName,$email $username
# Did adduser work? what to do if there is an error?
# Gives exit status 1 if adduser failed or generated error
if [ $? -eq 0 ]
then
echo "Linux User account for ${FirstName} $LastName was created
successfully. "
else
echo '!!!!!! User account was not added. AddUser Returned exit status '$?'
!!!!!!'
exit 1
fi
# Generate a strong, 16 characters, random password
Password=`< /dev/urandom tr -dc _A-Z-a-z-0-9\%\&\*\$\#\@\! | head -c${1:-16};echo;`
# Create a directory to store the information we will need to provide to the user later
mkdir $username
# Generate a message for the user and store in account_info.txt
echo "Hello $FirstName" > ./$username/account_info.txt
echo "You have been granted a user account on our system. " >> ./$username/account_info.txt
echo "Your User Name is: " $username >> ./$username/account_info.txt
echo "Your randomly generated Passphrase is: " $Password >> ./$username/account_info.txt
echo "You are being provided with your own RSA private key. The server will be configured with your public key in order to allow you access to server via SSH. " >> ./$username/account_info.txt
echo "Make sure to protect and guard your private key and passphrase at all costs! " >> ./$username/account_info.txt
#SSH DIRS
#echo "creating /home/${username}/.ssh directory"
#mkdir /home/${username}/.ssh
#ssh-keygen -t rsa -N "" -f /home/${username}/.ssh/authorized_keys
ssh-keygen -t rsa -N "$FirstName $LastName" -C "my keys" -f ./$username/id_rsa
# Did ssh-keygen work? if failed, delete the user account and home directory, also give exit Status 2
if [ $? -eq 0 ]
then
    echo "RSA key was generated successfully"
else
    echo '!!!!!! RSA Key was not created, ssh-keygen exit status '$?' !!!!!!'
    echo "Undoing the changes made to system so far"
    deluser $username && rm -r /home/$username
    exit 2
fi
#check if the dir exists
if [ -d "/home/${username}/.ssh" ] 
then
    mv ./$username/id_rsa.pub /home/${username}/.ssh/authorized_keys
    echo "The authorised keys file was placed in user's folder."
else
   echo "creating /home/${username}/.ssh directory"
   mkdir /home/${username}/.ssh
   chmod +777 /home/${username}/.ssh
   chmod +xwr /home/${username}/.ssh/
   mv ./$username/id_rsa.pub /home/${username}/.ssh/authorized_keys
   echo "The authorised keys file was placed in user's folder."
fi
