#!/bin/bash

SERVER=$1
TIMEOUT=25
RETVAL=0
TIMESTAMP=`echo | date`
EXPIRE_DATE=`echo | openssl s_client -connect $SERVER:443 -servername $SERVER -tlsextdebug 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d'=' -f2`
EXPIRE_SECS=`date -d "${EXPIRE_DATE}" +%s`
EXPIRE_TIME=$(( ${EXPIRE_SECS} - `date +%s` ))
if test $EXPIRE_TIME -lt 0
then
RETVAL=0
else
RETVAL=$(( ${EXPIRE_TIME} / 24 / 3600 ))
fi

echo ${RETVAL}