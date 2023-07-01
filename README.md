# Send Emails Using Bash in Synology

I have made many bash scripts to automate things on my synology systems and many if not all of them send me emails if things are not correct.

I wanted to share this with anyone who wishes to also send emails using bash in synology DSM.

# Getting start

1. Open setting.json file.
2. Change the to\_address field to your own sender's email address.
3. Change the from\_address field to the recipient's email address.
4. Save and close setting.json file.
5. Open email\_contents.txt and change it to the content you want to send out, then save and close.
6. Execute `bash email_send_one.sh`.
7. Check out your mailbox!

If you want to send an email to all users, just follow the above steps to set up setting.json (you can skip step 2), and then run bash `email_send_all.sh`.

# Introduction to setting.json Parameters

## information
-	to\_address  
	Recipient's email address  
-	from\_address  
	Sender's email address  

## content\_file
-	name  
	File name where the email content is located  
-	location  
	Location of the file where the email content is

## subject
Subject of the email

## sending\_mode
Which protocol to use to send the email, currently can choose "ssmtp" or "mail server"

## user\_list\_location
Email addresses of the users who will receive the email, default is `/etc/synouser.conf`
The format is as follows:
```txt
#$_@UID__INDEX@_$2000$
admin:0:
user1:0:user1@email.com
user2:0:user2@email.com
user3:0:user3@email.com
```

# Information

The issue is synology does not have a built in sendmail function UNLESS you have Mail Plus server installed, running, and properly configured. It also does not have a built in "mail" command either.

You can use the "ssmtp" command which uses the Synology System level notification SMTP server to send the emails. this allows email notifications without the need of Mail Plus Server installed or even running.

below I have code that allows you to choose between either "sendmail" or "ssmtp"

The "issue" however is performance

1. sending emails using the "sendmail" function only took 0.17 seconds to execute. this is because Mail Plus Server receives the email and then queues it and sends it along in parallel to the script execution.

2. sending emails using "ssmtp" took 2.673 seconds or over 15x time longer PER EMAIL. this is because this command performs all of the direct SMTP server communications and data transmissions right then and there so the script has to wait for the command to finish and you get no parallel processing.

3. running Mail Plus Server uses a fairly surprising amount of RAM so if you want faster email transmissions then you sacrifice RAM usage, or you get slower email transmissions but save a lot on RAM

another benefit of Mail Plus server is because it performs a queue if the email fails to send, it will try again later, where the ssmtp option will not unless the script executes again. You also get a benefit in Mail Plus Server that you can see a history of all the emails sent if you wish to see any of those logs.

example of performance
```
#running script with last parameter set to "0" to use "ssmtp" command
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
```
