#!/bin/bash

# Check if required packages are available
docker --version
if [ $? -eq 0 ]
then
  echo "docker package is available."
else
  echo "docker package is not  available."
  exit
fi

# Check if environment variables are set
if [ -z "${REGISTRY_HOST}" ];
then
  echo "Environment variable REGISTRY_HOST is not set."
  exit
fi
if [ -z "${DESIRED_TAG}" ];
then
  echo "Environment variable DESIRED_TAG is not set."
  exit
fi
if [ -z "${TOKEN_USERNAME}" ];
then
  echo "Environment variable TOKEN_USERNAME is not set."
  exit
fi
if [ -z "${TOKEN_PASSWORD}" ];
then
  echo "Environment variable TOKEN_PASSWORD is not set."
  exit
fi

./prepare.sh

# Build docker images
sudo docker build ./demo-portal -t ${REGISTRY_HOST}/demo-portal:${DESIRED_TAG}
sudo docker build ./fc-server -t ${REGISTRY_HOST}/fc-server:${DESIRED_TAG}

# Push new docker images
sudo docker login -u ${TOKEN_USERNAME} -p ${TOKEN_PASSWORD} ${REGISTRY_HOST}

sudo docker push ${REGISTRY_HOST}/demo-portal:${DESIRED_TAG}
sudo docker push ${REGISTRY_HOST}/fc-server:${DESIRED_TAG}