#!/bin/sh

check_data() {
	if [ ! -d data ]
	then
		mkdir data
	fi
	cd data
}

check_eula() {
	if [ ! -f eula.txt ]
	then
	    echo "eula=true" > eula.txt
	fi
}

start_spigot() {
	java \
		-d64 \
		-Xms1G -Xmx8G \
		-jar ../spigot-${MC_VERSION}.jar \
		-o true \
		nogui \
		-W worlds
}

if [ -z "${MC_VERSION}" ]; then
	MC_VERSION=latest
fi

BINDIR=$(dirname "$(readlink -fn "$0")")
cd "$BINDIR"

check_data
check_eula
while true
	do
		start_spigot
		echo "Sleeping for 5 seconds... hit control-C to exit"
		sleep 5
	done
