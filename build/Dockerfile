# -----------------------------------------------------------------------------
# winguru/minecraft-spigot-builder
#
# Builds a docker image for building a Minecraft Spigot server
# (https://www.spigotmc.org/)
# -----------------------------------------------------------------------------

# Base image is the latest Long-Term Support (LTS) version of Ubuntu, 18.04
FROM   ubuntu:18.04

# Make sure we don't get notifications we can't answer during building.
ENV    DEBIAN_FRONTEND noninteractive

# Update base system and add dependencies for Java development environment
RUN apt-get update \
	&& apt-get dist-upgrade --yes \
	&& apt-get install --yes --no-install-recommends \
		bzip2 \
		ca-certificates \
		g++ \
		gcc \
		git \
		make \
		openjdk-8-jdk \
		python \
		wget \
		unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Add Spigot BuildTools Java Archive
RUN wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

# Fix for openjdk-8 bug, see https://stackoverflow.com/questions/53010200/maven-surefire-could-not-find-forkedbooter-class
ENV _JAVA_OPTIONS -Djdk.net.URLClassPath.disableClassPathURLCheck=true

# Set requested version of Minecraft to build
ENV MC_VERSION latest

CMD java -jar BuildTools.jar --rev ${MC_VERSION}
