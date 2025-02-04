#!bin/bash

if [ -n "$1" ]
then
  exit 0
fi

CN="$1"

# generate server key
cd /root/ca
openssl genrsa -aes256 \
      -out intermediate/private/${CN}.key.pem 2048
chmod 400 intermediate/private/${CN}.key.pem

# generate server CSR
cd /root/ca
openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/${CN}.key.pem \
      -new -sha256 -out intermediate/csr/${CN}.csr.pem

# sign server CSR with intermediate CA key
cd /root/ca
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/${CN}.csr.pem \
      -out intermediate/certs/${CN}.cert.pem
chmod 444 intermediate/certs/${CN}.cert.pem

# view server certificate
cd /root/ca
openssl x509 -noout -text \
      -in intermediate/certs/${CN}.cert.pem

# verify server certificate
cd /root/ca
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/${CN}.cert.pem

exit 0
