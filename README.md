# minecraft-spigot
Docker container for a Minecraft Spigot Server

## Running the Minecraft Spigot containter

To run the container directly using docker (mainly for just testing), run the following command:</br>
`docker run -it --name mc-spigot -p 25565:25565 winguru/minecraft-spigot`

To run the container using docker-compose with persistent local storage, create the following `docker-compose.yml` file:
<pre>
#
# Launches Minecraft Spigot/CraftBukkit Server
#
# - Docker-compose 1.16 (min) required
#
version: '2.4'
services:
  spigot:
    image: "winguru/minecraft-spigot:latest"
    restart: always
    ports:
      - "25565:25565" # Minecraft server port
    volumes:
      - ./volumes/spigot-data/:/opt/spigot/data
</pre>

To verify that the docker-compose file works properly, run the following command:</br>
`docker-compose up`</br>

Type `CTRL-C` to stop the minecraft container</br>

## Startup script using docker-compose and screen
Here is a sample `start.sh` BASH script file that uses the above `docker-compose.yml` file and **screen** to manage the server:
<pre>
#!/bin/bash
SCREEN='spigot'
NAME='Minecraft Spigot Server'
CMD='docker-compose run --service-ports --rm spigot'

cd `dirname $0`
docker-compose down
docker-compose pull
if ! screen -ls ${SCREEN} | grep -q ${SCREEN}; then
  echo -n No existing ${NAME} session detected, starting server...
  screen -d -m -S ${SCREEN} ${CMD}
  echo "Done!"
else
  echo Existing ${NAME} session decteded... Aborted!
fi
</pre>
To start the server, run the following command:</br>
`./start.sh`</br>

To connect to the server with screen, run the following command:</br>
`screen -r spigot`

To detach from the screen session, type `CTRL-A`, `CTRL-D`.
