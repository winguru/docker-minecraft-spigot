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
