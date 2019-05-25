#!/bin/bash

JSON=$(for i in `cat /etc/zabbix/scripts/ssl_smtp.txt`; do printf "{\"{#DOMAIN_SMTP}\":\"$i\"},"; done | sed 's/^\(.*\).$/\1/')
printf "{\"data\":["
printf "$JSON"
printf "]}"