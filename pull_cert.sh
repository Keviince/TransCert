#!/bin/bash

# Certificate server address
CERT_SERVER="protocol://ip:port"

# operations after pulled certificate
after_pull() {
	systemctl force-reload nginx
}

read_params() {
	CERT_DOMAIN=""
	CERT_PASSWORD=""
	CERT_LOCATION=""
	while [ $# -gt 0 ]; do
		case "$1" in
			--domain=*)
				CERT_DOMAIN="${1#*=}"
				;;
			--password=*)
				CERT_PASSWORD="${1#*=}"
				;;
			--location=*)
				CERT_LOCATION="${1#*=}"
				;;
			--help)
				show_help
				;;
			*)
				echo "Unknown Argument: $1"
				;;
		esac
		shift
	done
	if [ -z $CERT_DOMAIN ] || [ -z $CERT_PASSWORD ] || [ -z $CERT_LOCATION ]; then
		show_help
	fi
}

check_cert_update() {
	# 1: Certificate need to be decompressed
	# 0: Certificate is up to date
	local LOCAL_CERT_GPG=$CERT_LOCATION"/"$CERT_DOMAIN".tgz.gpg"
	if [ -f $LOCAL_CERT_GPG ]; then
		echo "Local certificate found. Checking SHA256 Hash..."
		local REMOTE_CERT_SIG_URL=$CERT_SERVER"/"$CERT_DOMAIN"/"$CERT_DOMAIN".sig"
  		local CERT_PEM=$CERT_LOCATION"/"$CERT_DOMAIN".pem"
    		local CERT_KEY=$CERT_LOCATION"/"$CERT_DOMAIN".key"
      		local LOCAL_CERT_SIG=$(cat $CERT_PEM $CERT_KEY | sha256sum | awk '{print $1}')
		REMOTE_CERT_SIG=$(curl --silent $REMOTE_CERT_SIG_URL)
		if [ "$LOCAL_CERT_SIG" == "$REMOTE_CERT_SIG" ]; then
			echo "Local certificate is up to date."
			return 0
		else
			echo "Local certificate is outdated. Downloading..."
			local REMOTE_CERT_GPG=$CERT_SERVER"/"$CERT_DOMAIN"/"$CERT_DOMAIN".tgz.gpg"
			curl --silent $REMOTE_CERT_GPG -o $LOCAL_CERT_GPG
			return 1
		fi
	else
		echo "No local certificate found. Downloading..."
		local REMOTE_CERT_GPG=$CERT_SERVER"/"$CERT_DOMAIN"/"$CERT_DOMAIN".tgz.gpg"
		curl --silent $REMOTE_CERT_GPG -o $LOCAL_CERT_GPG
		return 1
	fi
}

cert_decompress() {
	echo "Decompressing certificate..."
	local LOCAL_CERT_GPG=$CERT_LOCATION"/"$CERT_DOMAIN".tgz.gpg"
	gpg --batch --yes --passphrase $CERT_PASSWORD -q -d $LOCAL_CERT_GPG | tar xz -C $CERT_LOCATION
}

show_help() {
  echo "Usage: sh $0 --domain=[Domain] --password=[Password] --location=[Location]"
  echo "Example:"
  echo "--domain=www.keviince.com	Domain Name"
  echo "--password=ExamplePWD		Decompress Password"
  echo "--location=/etc/nginx/cert	Certificate Home"
  echo "--help				Show Help"
  exit 0
}

main() {
	read_params "$@"
	echo "Start pulling "$CERT_DOMAIN"..."
	check_cert_update
	if [ $? -eq 1 ]; then
		cert_decompress
  		after_pull
	fi
	echo "Finish pulling "$CERT_DOMAIN"."
}

main "$@"
