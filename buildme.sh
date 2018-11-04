MC_VERSION=1.13.2
export MC_VERSION
BUILD_DIR=build
TARGET_DIR=target

link_latest_file() {
	# $1 Directory to operate in
	# $2 File prefix
	# $3 File suffix
	[ -h $1/$2-latest.$3 ] && rm $1/$2-latest.$3
	LATEST=`ls -1 $1/$2-*.$3 | sort -Vr | head -1`
	ln -sr ${LATEST} $1/$2-latest.$3
}

make_builder() {
	docker build ${BUILD_DIR} -t winguru/minecraft-spigot-builder:${MC_VERSION}
	docker tag winguru/minecraft-spigot-builder:${MC_VERSION} winguru/minecraft-spigot-builder:latest
}

run_builder() {
	docker run --name mc-spigot-builder -e MC_VERSION=${MC_VERSION} winguru/minecraft-spigot-builder 
	[ ! -d ${TARGET_DIR}/jarfiles ] && mkdir ${TARGET_DIR}/jarfiles 
	FILES=`docker logs mc-spigot-builder 2>&1 | tail -10 | grep "Saved as" | cut -c16-`
	for i in ${FILES}; do docker cp mc-spigot-builder:${i} ${TARGET_DIR}/jarfiles/; done
	link_latest_file ${TARGET_DIR}/jarfiles spigot jar
	link_latest_file ${TARGET_DIR}/jarfiles craftbukkit jar
}

make_spigot_server() {
	docker build ${TARGET_DIR} --build-arg MC_VERSION -t winguru/minecraft-spigot:${MC_VERSION}
	docker tag winguru/minecraft-spigot:${MC_VERSION} winguru/minecraft-spigot:latest
}

run_spigot_server() {
	docker run -it --name mc-spigot-${MC_VERSION} -e MC_VERSION=${MC_VERSION} winguru/minecraft-spigot
}

cleanup_spigot_server() {
	docker rm mc-spigot-${MC_VERSION}
}

# Step 1: Create docker Java Development (JDK) build environment 
make_builder

# Step 2: Compile Spigot server Java Archive (JAR)
run_builder

# Step 3: Create docker Spigot Server
make_spigot_server

# Step 4: Verify Spigot Server runs poperly
run_spigot_server

# Step 5: Cleanup and remove docker container
cleanup_spigot_server
