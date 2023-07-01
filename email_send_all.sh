#!/bin/bash


toAddress=`jq -r '.information.to_address' setting.json`
fromAddress=`jq -r '.information.from_address' setting.json`

fileName=`jq -r '.content_file.name' setting.json`
fileLocation=`jq -r '.content_file.location' setting.json`
if [ "${fileLocation}" = "\${PWD}" ];
then
	fileLocation=$(pwd)
fi

subject=`jq -r '.subject' setting.json`

mode=`jq -r '.sending_mode' setting.json`
if [ "${mode}" = "ssmtp" ];
then
    mode=0
elif [ "${mode}" = "mail server" ];
then
    mode=1
fi

userMailList=`cat $( jq -r '.user_list_location' setting.json ) | tail -n +2 | cut -d ':' -f3`
for toAddress in ${userMailList}
do
	echo ${toAddress}
	bash $(dirname "$0")"/repository/send.sh" ${toAddress} ${fromAddress} ${fileLocation} ${fileName} ${subject} ${mode}
done
