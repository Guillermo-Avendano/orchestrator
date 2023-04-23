#!/bin/sh
if [ $# -ne 1 ]; then
  echo "Invalid numbers of arguments supplied"
  echo "Usage is generate-cert.sh <YourCertificateURL>"
  echo "It will generate a YourCertificateURL.key and a YourCertificateURL.crt Usage in the current directory"
  echo "It will also generate a Base64 encoded version at base64_YourCertificateURL.key and base64_YourCertificateURL.crt in the current directory"
  exit 1
else
  hostname=$1
  openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "${hostname}.key" -out "${hostname}.crt" -subj "/CN=${hostname}" -addext "subjectAltName=DNS:${hostname}" -addext 'extendedKeyUsage=serverAuth,clientAuth'
  base64 -w0 "${hostname}.key" > "base64_${hostname}.key"
  base64 -w0 "${hostname}.crt" > "base64_${hostname}.crt"
fi
