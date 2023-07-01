#!/bin/bash

# to_email_address=${1}
# from_email_address=${2}
# email_content_file_location=${3}
# email_content_file_name=${4}
# subject=${5}
# use_ssmtp (value =0) or use mail plus server (value =1) ${6}

if [ $# -gt 6 ]; then
	echo -e "Too more arguments.\n"
	exit $?
fi

if [[ "${3}" == "" || "${4}" == "" ]]; then
	echo "Incorrect data was passed to the \"send_email\" function, cannot send email"
	exit $?
fi

# make sure directory exists
if [ ! -d "${3}" ]; then
	echo "cannot send email as directory \"${3}\" does not exist"
	exit $?
fi

# make sure directory is writable
if [ ! -w "${3}" ]; then
	echo "cannot send email as directory \"${3}\" does not have WRITE permissions"
	exit $?
fi

# make sure directory is readable
if [ ! -r "${3}" ]; then
	echo "cannot send email as directory \"${3}\" does not have READ permissions"
	exit $?
fi

if [[ "${1}" == "" || "${2}" == "" || "${5}" == "" ]]; then
	echo -e "\n\nOne or more email address parameters [to, from, subject, mail_body] was not supplied, Cannot send an email"
	exit $?
fi

# replace the email_contents.txt marks
cat /dev/null > ${3}"/"${4}"_temp"
while IFS= read -r line
do
	if [ ` echo $line | grep -c "#Z1#" ` -ne 0 ];
	then
		echo "${line/\#Z1\#/${1}}" >> ${3}"/"${4}"_temp"
	elif [ ` echo $line | grep -c "#Z2#" ` -ne 0 ];
	then
		echo "${line/\#Z2\#/${2}}" >> ${3}"/"${4}"_temp"
	elif [ ` echo $line | grep -c "#Z3#" ` -ne 0 ];
	then
		echo "${line/\#Z3\#/${5}}" >> ${3}"/"${4}"_temp"
	else
		echo "$line" >> ${3}"/"${4}"_temp"
	fi
done < ${3}"/"${4}
													
if [ ${6} -eq 1 ]; #use Synology Mail Plus server "sendmail" command
then	
	# verify MailPlus Server package is installed and running as the "sendmail" command is not installed in synology by default. the MailPlus Server package is required
	install_check=$(/usr/syno/bin/synopkg list | grep MailPlus-Server)
	if [ "$install_check" = "" ]; then
		echo "WARNING!  ----   MailPlus Server NOT is installed, cannot send email notifications"
		exit $?
	fi

	Mstatus=$(/usr/syno/bin/synopkg is_onoff "MailPlus-Server")
	if [ "$Mstatus" = "package MailPlus-Server is turned on" ]; then
		email_response=$(sendmail -t < ${3}/${4}"_temp"  2>&1)
		if [[ "$email_response" == "" ]]; then
			echo -e "Email Sent Successfully\n"
		else
			echo -e "\n\nWARNING -- An error occurred while sending email. The error was: $email_response\n\n"
		fi					
	else
		echo "WARNING!  ----   MailPlus Server NOT is running, cannot send email notifications"
	fi
elif [ ${6} -eq 0 ]; then #use "ssmtp" command
	if ! command -v ssmtp &> /dev/null #verify the ssmtp command is available 
	then
		echo "Cannot Send Email as command \"ssmtp\" was not found"
	fi

	email_response=$(ssmtp ${1} < ${3}/${4}"_temp"  2>&1)
	if [[ "$email_response" == "" ]]; then
		echo -e "Email Sent Successfully\n"
	else
		echo -e "\n\nWARNING -- An error occurred while sending email. The error was: $email_response\n\n"
	fi	
else 
	echo "Incorrect parameters supplied, cannot send email"
fi

rm -f ${3}"/"${4}"_temp"


#root@Server2:/volume1/web/logging/testing# time bash email_test.sh
#
#Email Sent Successfully
#
#real    0m2.673s
#user    0m0.010s
#sys     0m0.009s

#running script with last parameter set to "1" to use "sendmail" command through Synology Mail Plus Server
#root@Server2:/volume1/web/logging/testing# time bash email_test.sh
#
#Email Sent Successfully

#real    0m0.170s
#user    0m0.101s
#sys     0m0.044s
#root@Server2:/volume1/web/logging/testing#
