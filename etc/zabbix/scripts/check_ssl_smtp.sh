#!/bin/bash

SERVER=$1
TIMEOUT=25
RETVAL=0
TIMESTAMP=`echo | date`
EXPIRE_DATE=`echo | openssl s_client -starttls smtp -connect $SERVER:25 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d'=' -f2`
EXPIRE_SECS=`date -d "${EXPIRE_DATE}" +%s`
EXPIRE_TIME=$(( ${EXPIRE_SECS} - `date +%s` ))
if test $EXPIRE_TIME -lt 0
then
RETVAL=0