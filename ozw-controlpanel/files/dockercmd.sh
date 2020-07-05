#!/bin/bash

# Set local time based on environment variable given
if [ ! -z {$TZ+x} ]
then
	echo "Setting Timezone $TZ"
	echo $TZ > /etc/timezone && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
fi

# Change device permissions based on environment variable given
if [ ! -z {$DEVICES+x} ]
then
	IFS=';'
	read -ra DEVS <<< "$DEVICES"
	for dev in "${DEVS[@]}"; do
		echo "Setting permission for device $dev"
	    chown ozw_user:ozw_user $dev
	done
fi

# Run OpenZwave Control Panel
sudo -u ozw_user /opt/ozwcp/ozwcp -p $PORT -c $CONFIG
