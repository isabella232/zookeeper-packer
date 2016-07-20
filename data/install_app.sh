#!/bin/bash

set -o errexit

YUM="yum --assumeyes"

ZK_HOME="/opt/zookeeper"
EXBT_HOME="/opt/exhibitor"
MAVEN_HOME="/usr/share/maven"
ZK_RELEASE="http://www.apache.org/dist/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz"
EXHIBITOR_POM="https://raw.githubusercontent.com/Netflix/exhibitor/d911a16d704bbe790d84bbacc655ef050c1f5806/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml"

JAVA_HOME="/usr/java/latest"
source /etc/profile

export PATH=${JAVA_HOME}/bin:${PATH}

grep '^networkaddress.cache.ttl=' ${JAVA_HOME}/lib/security/java.security || echo 'networkaddress.cache.ttl=60' >> ${JAVA_HOME}/lib/security/java.security


# Install Maven
MAVEN_VERSION=3.3.3
cd /usr/share
wget -q http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O - | tar xzf -
mv /usr/share/apache-maven-${MAVEN_VERSION} /usr/share/maven
ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

mkdir -p /opt

# Install ZK
curl -Lo /tmp/zookeeper.tgz ${ZK_RELEASE}
mkdir -p ${ZK_HOME}/transactions ${ZK_HOME}/snapshots
tar -xzf /tmp/zookeeper.tgz -C ${ZK_HOME} --strip-components=1
rm /tmp/zookeeper.tgz

# Install Exhibitor
mkdir -p ${EXBT_HOME}
curl -Lo ${EXBT_HOME}/pom.xml ${EXHIBITOR_POM}
mvn -f ${EXBT_HOME}/pom.xml package
ln -s ${EXBT_HOME}/target/exhibitor*jar ${EXBT_HOME}/exhibitor.jar


ZOOKEEPER_USER=zookeeper

groupadd -r $ZOOKEEPER_USER
useradd -g $ZOOKEEPER_USER -M -r $ZOOKEEPER_USER

# set permissions for zookeeper
mkdir -p /var/{lib,log}/zookeeper
chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER /var/{lib,log}/zookeeper
