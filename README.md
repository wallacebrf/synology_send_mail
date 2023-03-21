Send Emails using Bash in Synology

I have made many bash scripts to automate things on my synology systems and many if not all of them send me emails if things are not correct.

I wanted to share this with anyone who wishes to also send emails using bash in synology DSM.

the issue is synology does not have a built in sendmail function UNLESS you have Mail Plus server installed, running, and properly configured. It also does not have a built in "mail" command either.

You can use the "ssmtp" command which uses the Synology System level notification SMTP server to send the emails. this allows email notifications without the need of Mail Plus Server installed or even running.

below i have code that allows you to choose between either "sendmail" or "ssmtp"

the "issue" however is performance.

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
