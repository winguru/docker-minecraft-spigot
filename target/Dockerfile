# -----------------------------------------------------------------------------
# winguru/minecraft-spigot
#
# Builds a docker image for building a Minecraft Spigot server
# (https://www.spigotmc.org/)
# -----------------------------------------------------------------------------

# Base image is the latest Long-Term Support (LTS) version of Ubuntu, 18.04
FROM   openjdk:8-jre-slim

# Set requested version of Minecraft to build
ARG MC_VERSION=latest
ARG MC_DIR=/opt/spigot
ENV MC_VERSION ${MC_VERSION}

RUN mkdir -p ${MC_DIR}

COPY [ "jarfiles/spigot-${MC_VERSION}.jar", "spigot.sh", "${MC_DIR}/" ]

RUN ln -s ${MC_DIR}/spigot.sh .

CMD [ "./spigot.sh" ]
