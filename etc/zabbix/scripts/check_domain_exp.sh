#!/bin/sh

# получаем имя домена
SERVER=$1

# получаем имя зоны
ZONE=`echo $SERVER | sed 's/\./ /' | awk '{ print $2 }'`

# получаем дату протухания домена
# Должна вернуться в формате ГГГГ-ММ-ДД (год-месяц-день)
case "$ZONE" in
ru|net.ru|org.ru|pp.ru)
DATE=`whois $SERVER | grep paid-till | awk '{ print $2 }' | sed 's/\./-/g'`
;;
pp.ua)
DATE=`whois $SERVER | grep "Expiration Date:" | sed 's/Expiration Date://g;s/T/ /g' | awk '{ print $1 }'`
;;
com|net|media|academy)
# DATE=`whois $SERVER | grep "Registration Expiration Date:" | sed 's/Registrar Registration Expiration Date: //g;s/T/ /g' | awk '{ print $1 }'`
DATE=`whois $SERVER | grep "Registry Expiry Date:" | sed 's/Registry Expiry Date: //g;s/T/ /g' | awk '{ print $1 }'`
;;
com.ua|ua|kh.ua|kharkiv.ua)
DATE=`whois $SERVER | grep expires: | awk '{ print $2 }' | sed 's/\./-/g'`
;;
org)
DATE=`whois $SERVER | grep "Registry Expiry Date:" | sed 's/Registry Expiry Date: //g;s/T/ /g' | awk '{ print $1 }'`
;;
*)
DATE="$(whois $SERVER | awk '/[Ee]xpir.*[Dd]ate:/ || /[Tt]ill:/ || /expire/ {print $NF; exit;}')"
if test -z "$DATE"; then
#Отсутствует информация в Whois для домена
echo "-1"
continue
fi
esac

# считаем дни и выводим
expr \( `date --date="$DATE" +%s` - `date +%s` \) / 60 / 60 / 24
