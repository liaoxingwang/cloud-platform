#!/bin/bash

# image name
MODULE_NAME=$1
IMAGE_NAME="fkx/${MODULE_NAME}"
lastImageTag="1.0"
TIME=$2
PORT=0
IP='127.0.0.1'

case $MODULE_NAME in
  'jeecg-demo-cloud-start') PORT=7002 ; IP='192.168.10.201'; DOCKER_OPTS="--ip=${IP}" ;;
  'jeecg-system-cloud-start') PORT=7001 ; IP='192.168.10.200'; DOCKER_OPTS="--ip=${IP}" ;;
  'jeecg-cloud-gateway') PORT=9999 ; IP='192.168.10.199'; DOCKER_OPTS="--ip=${IP}" ;;
  'jeecg-cloud-nacos') PORT=8848 ; IP='192.168.10.198'; DOCKER_OPTS="--ip=${IP} -e MYSQL-PWD=fkx@123456 -e MYSQL-USER=root -e MYSQL-HOST=192.168.10.196" ;;
  *) echo "undefined module name!" exit 1;;
esac


# maven build
export MAVEN_OPTS="$MAVEN_OPTS -Xms512m -Xmx512m"
echo $MAVEN_OPTS
/usr/local/apache-maven-3.6.3/bin/mvn -s /usr/local/apache-maven-3.6.3/conf/settings.xml clean install -T 1 -P test -f pom.xml -pl jeecg-server-cloud/${MODULE_NAME} -am || exit
echo "maven build success"

cd jeecg-server-cloud/${MODULE_NAME} || exit

# docker build
newImage="${IMAGE_NAME}:${lastImageTag}"
docker build -f Dockerfile --tag="${newImage}" .
echo "docker build success"

# stop and remove
docker ps --filter name="${MODULE_NAME}" -q | awk '{for(i=1;i<NF+1;i++) system("echo stop and remove containerId:"$i" && docker stop "$i" && docker wait "$i"  && docker rm "$i" ")}'
docker ps -a --filter name="${MODULE_NAME}" -q | awk '{for(i=1;i<NF+1;i++) system("echo remove containerId:"$i" && docker rm "$i" ")}'

# run
dockerName="${IMAGE_NAME#*/}-${lastImageTag}-$(date +%s)"
docker run -d --name "${dockerName}" --network=fkx_net -v /data/docker/project/"${MODULE_NAME}"/logs:/logs ${DOCKER_OPTS} "${IMAGE_NAME}:${lastImageTag}"

# delete dangling image
docker image prune -f

# test
#for ((i = 1; i < TIME; i++)); do
#  sleep 1
#  if ((1 == $(docker container ls --filter name="${dockerName}" --format "{{.ID}}" --filter status=running | wc -l))); then
#    echo "running success, cost:${i}s"
#    exit 0
#  fi
#done

# port test
currentTimestamp=$(date '+%s')
stopTimestamp=$(( currentTimestamp + TIME ))
while (( $(date '+%s') < stopTimestamp )); do
  sleep 1
  if [[ 'open' == $(nmap -sS -p ${PORT} ${IP} --max-rtt-timeout 3000ms | head -n +6 | tail -n -1 | awk '{print $2}' ) ]]; then
    echo "server port open success, cost:$(( $(date '+%s') - currentTimestamp ))s"
    exit 0
  fi
done


echo "container running fail!"
exit 1
