#!/bin/bash

function send_email(){
#to_email_address=${1}
#from_email_address=${2}
#log_file_location=${3}
#log_file_name=${4}
#subject=${5}
#mail_body=${6}
#use_ssmtp (value =0) or use mail plus server (value =1) ${7}

	if [[ "${3}" == "" || "${4}" == "" || "${7}" == "" ]];then
		echo "Incorrect data was passed to the \"send_email\" function, cannot send email"
	else
		if [ -d "${3}" ]; then #make sure directory exists
			if [ -w "${3}" ]; then #make sure directory is writable 
				if [ -r "${3}" ]; then #make sure directory is readable 
					local now=$(date +"%T")
					echo "To: ${1} " > ${3}/${4}
					echo "From: ${2} " >> ${3}/${4}
					echo "Subject: ${5}" >> ${3}/${4}
					#echo "" >> ${3}/${4}
					echo -e "\n$now - ${6}\n" >> ${3}/${4}
													
					if [[ "${1}" == "" || "${2}" == "" || "${5}" == "" || "${6}" == "" ]];then
						echo -e "\n\nOne or more email address parameters [to, from, subject, mail_body] was not supplied, Cannot send an email"
					else
						if [ ${7} -eq 1 ]; then #use Synology Mail Plus server "sendmail" command
						
							#verify MailPlus Server package is installed and running as the "sendmail" command is not installed in synology by default. the MailPlus Server package is required
							local install_check=$(/usr/syno/bin/synopkg list | grep MailPlus-Server)

							if [ "$install_check" = "" ];then
								echo "WARNING!  ----   MailPlus Server NOT is installed, cannot send email notifications"
							else
								local status=$(/usr/syno/bin/synopkg is_onoff "MailPlus-Server")
								if [ "$status" = "package MailPlus-Server is turned on" ]; then
									local email_response=$(sendmail -t < ${3}/${4}  2>&1)
									if [[ "$email_response" == "" ]]; then
										echo -e "\nEmail Sent Successfully" |& tee -a ${3}/${4}
									else
										echo -e "\n\nWARNING -- An error occurred while sending email. The error was: $email_response\n\n" |& tee ${3}/${4}
									fi					
								else
									echo "WARNING!  ----   MailPlus Server NOT is running, cannot send email notifications"
								fi
							fi
						elif [ ${7} -eq 0 ]; then #use "ssmtp" command
							if ! command -v ssmtp &> /dev/null #verify the ssmtp command is available 
							then
								echo "Cannot Send Email as command \"ssmtp\" was not found"
							else
								local email_response=$(ssmtp ${1} < ${3}/${4}  2>&1)
								if [[ "$email_response" == "" ]]; then
									echo -e "\nEmail Sent Successfully" |& tee -a ${3}/${4}
								else
									echo -e "\n\nWARNING -- An error occurred while sending email. The error was: $email_response\n\n" |& tee ${3}/${4}
								fi	
							fi
						else 
							echo "Incorrect parameters supplied, cannot send email" |& tee ${3}/${4}
						fi
					fi
				else
					echo "cannot send email as directory \"${3}\" does not have READ permissions"
				fi
			else
				echo "cannot send email as directory \"${3}\" does not have WRITE permissions"
			fi
		else
			echo "cannot send email as directory \"${3}\" does not exist"
		fi
	fi
}

send_email "to@email.com" "from@email.com" "/volume1/web/logging/notifications" "email_contents.txt" "email_test" "This is a test" 1


#running script with last parameter set to "1" to use "ssmtp" command
#root@Server2:/volume1/web/logging/testing# time bash email_test.sh
#
#Email Sent Successfully
#
#real    0m2.673s
#user    0m0.010s
#sys     0m0.009s

#running script with last parameter set to "0" to use "sendmail" command through Synology Mail Plus Server
#root@Server2:/volume1/web/logging/testing# time bash email_test.sh
#
#Email Sent Successfully

#real    0m0.170s
#user    0m0.101s
#sys     0m0.044s
#root@Server2:/volume1/web/logging/testing#