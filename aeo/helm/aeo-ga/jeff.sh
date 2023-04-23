#!/bin/bash
#variables
ZBASE=dc=zenadev,dc=asg,dc=com
ZSERVER=zenadev-asg.com
ZLDAP=ldap
ZPORT=389
printf "Enter LDAP Username:"
read USERNAME
DN=$(ldapsearch -x -H ${ZLDAP}://${ZSERVER}:${ZPORT} -b ${ZBASE}  -s sub "uid=${USERNAME}" | grep 'dn: ' | sed 's/dn: //g')
echo $DN
echo ldapsearch -H ${ZLDAP}://${ZSERVER}:${ZPORT} -b ${ZBASE} -D "${DN}" -W > /dev/null
ldapsearch -H ${ZLDAP}://${ZSERVER}:${ZPORT} -b ${ZBASE} -D "${DN}" -W 
exit`
EXITCODE=$?
if [[ ${EXITCODE} -eq 0 ]]; then
    echo "Auth success"
else
    echo "Auth failed"
    exit ${EXITCODE}
fi
