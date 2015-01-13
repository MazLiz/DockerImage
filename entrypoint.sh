#! /bin/sh
echo "Sono nel file sh"
pwd
cd /jena-fuseki-1.1.1
pwd
nohup ./fuseki-server --update --port 3030 --loc /tmp/fusekidir /modaclouds/kb > /tmp/fuseki.log 2>&1 &
echo "ho acceso fuseki"
sleep 10s
ps aux | grep java
java -jar /usr/share/jenkins/jenkins.war


