#!/bin/sh
#
# This script adds an ssl certificate to the linux NSS Shared DB of certs.
# 
# usage:  import-cert.sh remote.host.name [port]
# you may need to intall libnss3-tools and curl
#
# To see which certs are in your DB:   certutil -L -d sql:$HOME/.pki/nssdb
# To delete a cert from your DB:       certutil -D -n <THE_NAME> -d sql:$HOME/.pki/nssdb
# To list details of a cert:           certutil -d sql:$HOME/.pki/nssdb -L -n  <THE_NAME>

# This script was taken from: http://blog.avirtualhome.com/2010/02/02/adding-ssl-certificates-to-google-chrome-linux-ubuntu/
# This page may also be of help: http://code.google.com/p/chromium/wiki/LinuxCertManagement

#create cert directory if not found
if [ ! -e $HOME/.pki/nssdb ]
then
echo -e “===========================\nNo Database found. Creating one…\n=================================”
mkdir -p $HOME/.pki/nssdb
cd $HOME/.pki/nssdb
certutil -N -d sql:.
fi

REMHOST=$1

#is not host is given list the certs we have
if [ -z $REMHOST ]
then
certutil -L -d sql:$HOME/.pki/nssdb
exit 0
fi

#download cert
REMPORT=${2:-443}
exec 6>&1
exec > $REMHOST
echo | openssl s_client -connect ${REMHOST}:${REMPORT} 2>&1 |sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'

#add cert
#certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "$REMHOST" -i $REMHOST 
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "$REMHOST" -i $REMHOST 

exec 1>&6 6>&-

