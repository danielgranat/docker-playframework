#!/usr/bin/env bash

read -r -d '' PLAY_VERSIONS <<-LIST
1.2.7.2
1.2.6.2
1.2.5.6
1.3.4
1.4.2
LIST

read -r -d '' WARN_HEADER <<-EOM
#
# AUTO-GENERATED - DO NOT EDIT THIS FILE
# EDIT Dockerfile.template AND RUN update.sh
# 
# GENERATED: $(date -u)
#
EOM

for PLAY_VERSION in $(echo ${PLAY_VERSIONS}); do
  IMAGE_VERSION=${PLAY_VERSION}-alpine
  mkdir -p ${IMAGE_VERSION}
  
  echo "${WARN_HEADER}" > ${IMAGE_VERSION}/Dockerfile
  sed "s/__PLAY_VERSION__/${PLAY_VERSION}/g" Dockerfile.template >> ${IMAGE_VERSION}/Dockerfile
done

OLD_PWD=$(pwd)

for PLAY_VERSION in $(echo $PLAY_VERSIONS); do
  IMAGE_VERSION=${PLAY_VERSION}-alpine

  cd ${IMAGE_VERSION}
  docker build -t play:${IMAGE_VERSION} .
  cd ${OLD_PWD}

  docker run --rm -it play:${IMAGE_VERSION}
done

docker images play

# Push to socialmetrix/play repo
for PLAY_VERSION in $(echo $PLAY_VERSIONS); do
  IMAGE_VERSION=${PLAY_VERSION}-alpine
  docker tag play:${IMAGE_VERSION} socialmetrix/play:${IMAGE_VERSION}
  docker push socialmetrix/play:${IMAGE_VERSION}
done