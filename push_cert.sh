#!/bin/bash

# certificate to publish
# often web server directory
CERT_HOME="/home/Certs"

# acme.sh script home
ACME_HOME="/root/.acme.sh"

# encryption password
CERT_PASSWORD="YourEncryptionPassword"

CERT_ARRAY=$($ACME_HOME/acme.sh --list | awk '{print $1}' | sed '1d')
CERT_COUNT=$($ACME_HOME/acme.sh --list | awk '{print $1}' | sed '1d' | wc -l)

# push your certificate(s) to web server directory
push_cert() {
        echo "Start pushing "$1"..."
        local CERT_TARGET=$CERT_HOME"/"$1
        mkdir -p $CERT_TARGET
        local CERT_DOMAIN=$1
        local CERT_LOCATION=$ACME_HOME"/"$CERT_DOMAIN"_ecc/"
        local CERT_FULLCHAIN=$CERT_LOCATION"fullchain.cer"
        local CERT_PEM=$CERT_LOCATION$CERT_DOMAIN".pem"
        local CERT_KEY=$CERT_LOCATION$CERT_DOMAIN".key"
        cp -f $CERT_FULLCHAIN $CERT_PEM
        local CERT_TGZ=$CERT_HOME"/"$CERT_DOMAIN"/"$CERT_DOMAIN".tgz"
        local CERT_GPG=$CERT_TGZ".gpg"
        local CERT_SIG=$CERT_HOME"/"$CERT_DOMAIN"/"$CERT_DOMAIN".sig"
        tar -czPf $CERT_TGZ --transform "s,^.*/.*/,,g" $CERT_PEM $CERT_KEY
        gpg --batch --yes --passphrase $2 -q -c $CERT_TGZ
        sha256sum $CERT_TGZ | awk '{print $1}' > $CERT_SIG
        rm -f $CERT_TGZ $CERT_PEM
        echo "Finish pushing "$1"..."
        return 0
}

check_cert_count() {
        if [ $CERT_COUNT -eq 0 ]; then
                echo "No certificate found."
                exit 1
        else
                echo $CERT_COUNT" certificate(s) found. Start pushing..."
        fi   
}

main() {
        check_cert_count
        for CERT in $CERT_ARRAY
        do
                push_cert $CERT $CERT_PASSWORD
        done
}

main
