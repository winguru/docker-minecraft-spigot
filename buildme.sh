MC_VERSION=1.15.1
export MC_VERSION
BUILD_DIR=build

link_latest_file() {
	# $1 Directory to operate in
	# $2 File prefix
	# $3 File suffix
	[ -h $1/$2-latest.$3 ] && rm $1/$2-latest.$3
	LATEST=`ls -1 $1/$2-*.$3 | sort -Vr | head -1`
	ln -sr ${LATEST} $1/$2-latest.$3
}

make_spigot_server() {
	docker build ${BUILD_DIR} --build-arg MC_VERSION \
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
}

case "$1" in
	build)	
		echo "Step 1: Build Spigot docker image"
		make_spigot_server
		;;
	run)	
		echo "Step 2: Perform test-run validation of docker containter"
		run_spigot_server	
		;;
	push)	
		echo "Step 3: Push Spigot docker image to docker-hub"
		push_spigot_server
		;;
	clean)	
		echo "Step 4: Cleanup and remove docker containers and images"
		cleanup_docker
		;;
	complete)
		echo "Perform a complete auto-build"
		;;	
	*)	
		echo "Usage: $0 {build|run|push|clean}"
		exit 2
		;;
esac
exit 0

