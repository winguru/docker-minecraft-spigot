# -----------------------------------------------------------------------------
# winguru/minecraft-spigot
#
# Builds a docker image for building a Minecraft Spigot server
# (https://www.spigotmc.org/)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# First-stage build for minecraft-spigot builder image
# -----------------------------------------------------------------------------

# Base image for builder is the latest Long-Term Support (LTS) version of Ubuntu, 18.04
FROM   ubuntu:18.04 as builder

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
ARG MC_VERSION=1.13.2
ENV MC_VERSION ${MC_VERSION}

RUN java -jar BuildTools.jar --rev ${MC_VERSION}

# -----------------------------------------------------------------------------
# Second-stage build for minecraft-spigot image
# -----------------------------------------------------------------------------

# Base image is the OpenJDK Java Runtime Slim (Headless) environment
FROM   openjdk:8-jre-slim

# Set requested version of Minecraft to build
ARG MC_VERSION=1.13.2
ENV MC_VERSION ${MC_VERSION}

# Set location of Minecraft server files
ARG MC_DIR=/opt/spigot

RUN mkdir -p ${MC_DIR}/data

COPY --from=builder [ "spigot-${MC_VERSION}.jar", "${MC_DIR}/" ]
COPY [ "spigot.sh", "${MC_DIR}/" ]

RUN ln -s ${MC_DIR}/spigot.sh .

EXPOSE 25565

VOLUME ${MC_DIR}/data

CMD [ "./spigot.sh" ]
