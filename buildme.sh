MC_VERSION=1.14.1
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
	docker build ${TARGET_DIR} --build-arg MC_VERSION \
		-t winguru/minecraft-spigot:${MC_VERSION} \
		-t winguru/minecraft-spigot:latest \
		-t winguru/minecraft-spigot-nightly:latest
}

run_spigot_server() {
	docker run -it --name mc-spigot-${MC_VERSION} -e MC_VERSION=${MC_VERSION} -p 25565:25565 winguru/minecraft-spigot
}

push_spigot_server() {
	docker push winguru/minecraft-spigot:${MC_VERSION}
	docker push winguru/minecraft-spigot:latest
}

cleanup_docker() {
	docker rm mc-spigot-${MC_VERSION}
	docker rm mc-spigot-builder
}

case "$1" in
prep)        echo "Step 1: Prepare docker Java Development (JDK) build environment"
             make_builder
             ;;
compile)     echo "Step 2: Compile Spigot server Java Archive (JAR)"
             run_builder
             ;;
build)       echo "Step 3: Build Spigot docker image"
             make_spigot_server
             ;;
run)         echo "Step 4: Perform test-run validation of docker containter"
             run_spigot_server	
             ;;
push)        echo "Step 5: Push Spigot docker image to docker-hub"
             push_spigot_server
             ;;
clean)       echo "Step 6: Cleanup and remove docker containers and images"
             cleanup_docker
             ;;
*)           echo "Usage: $0 {prep|compile|build|run|push|clean}"
             exit 2
             ;;
esac
exit 0

