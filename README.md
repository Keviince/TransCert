# TransCert
A simple tool to allow you to pull you ssl certificate from a server.  

[English](https://github.com/Keviince/TransCert/blob/main/README.md)   [简体中文](https://github.com/Keviince/TransCert/blob/main/README_zh.md)

## Requirements
[acme.sh](https://github.com/acmesh-official/acme.sh)  
gpg  
tar  
sha256sum  

## Usage
### push_cert.sh
After get new certificate via acme.sh, run this script to pack your certificate and generate a sha256 hash for it.  
After that this script will autimaticly move the certificate and its hash to web server directory so that clients can access them.  

Once you have download this script, remember to change this 3 variables in it.  
|Variable|Description|
|--------|-----------|
|CERT_HOME|The place to store certificates for web server to publish.|
|ACME_HOME|The place you installed the acme.sh in.|
|CERT_PASSWORD|The password you want to encrypt the certificates.|

___

### pull_cert.sh
Run this script will check local certificate's sha256 hash.  
If doesn't match the sig on server or there is no local certificate, the script will autimaticly download the latest certificate on the server and decrypt & decompress it.  
After replace the latest certificate with the old one, this script will reload the nginx (can be whatever operations).  

Once you have download this script, remember to change this 2 variables in it.  
|Variable|Description|
|--------|-----------|
|CERT_SERVER|The url of certificate publish server.|
|after_pull|The operations need to be done after certificate installed.|  

When using this script to pull certificate from server you need to provide this 3 arguments.
|Variable|Description|
|--------|-----------|
|--domain|The domain of the certificate.|
|--location|The place you want the certificate in.|
|--password|The password to decrypt the certificates.|  

Usage:  
`
sh pull_cert.sh --domain=[Domain] --password=[Password] --location=[Location]
`
