#!/bin/bash

# Check if required packages are available
mvn --version
if [ $? -eq 0 ]
then
  echo "mvn package is available."
else
  echo "mvn package is not  available."
  exit
fi
git --version
if [ $? -eq 0 ]
then
  echo "git package is available."
else
  echo "git package is not  available."
  exit
fi

# Clone code repository in temporary directory
mkdir temp
git clone https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service.git ./temp

# Package thee required jar files
cd ./temp
git checkout bfbd93db0a5547ef0e136ed4149139f0a11bcffa
export MAVEN_DIR=$(pwd)
export MAVEN_OPTS="-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=${MAVEN_DIR}/.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
mvn --batch-mode --errors -fn --show-version -Dskip=true -DinstallAtEnd=true package jib:build -am -U
cd ./..
cp -f ./temp/demo-portal/target/demo-portal-1.0.0.jar ./demo-portal/demo-portal-1.0.0.jar
cp -f ./temp/fc-service-server/target/fc-service-server-1.0.0.jar ./fc-server/fc-service-server-1.0.0.jar

rm -rf ./temp