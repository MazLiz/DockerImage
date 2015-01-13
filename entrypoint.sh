#! /bin/sh
cd ..
cd ..
cd ..
cd /jena-fuseki-1.1.1
nohup ./fuseki-server --update --port 3030 --loc /tmp/fusekidir /modaclouds/kb > /tmp/fuseki.log 2>&1 &

java -jar /usr/share/jenkins/jenkins.war &


