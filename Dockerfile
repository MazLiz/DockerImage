# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# Jenkins 1.574
# git 1.9.1

# extend the most recent long term support Ubuntu version
FROM ubuntu:14.04

MAINTAINER MazLiz

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update 

# install wget, git, ecc..
RUN apt-get install -y wget git curl zip && rm -rf /var/lib/apt/lists/*

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# verify checksum
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven

#download fuseki server
RUN wget -qO- -O fuseki.zip http://archive.apache.org/dist/jena/binaries/jena-fuseki-1.1.1-distribution.zip && unzip fuseki.zip && rm fuseki.zip
#create fuseki-dir and start server
RUN mkdir -p /tmp/fusekidir
#RUN nohup ./fuseki-server --update --port 3030 --loc /tmp/fusekidir /modaclouds/kb >> /tmp/fuseki.log 2>&1 &

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_11
ENV filename jdk-8u11-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u11-b12/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

#download bash script from github
#ADD https://raw.githubusercontent.com/MazLiz/DockerImage/master/plugin_jenkins /configcli.sh
#RUN chmod 755 /configcli.sh

RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
RUN apt-get update
RUN apt-get install -y jenkins
RUN mkdir -p /jenkins/plugins
RUN (cd /jenkins/plugins && wget --no-check-certificate http://updates.jenkins-ci.org/latest/buildresult-trigger.hpi)
RUN (cd /jenkins/plugins && wget --no-check-certificate http://updates.jenkins-ci.org/latest/git-client.hpi)
RUN (cd /jenkins/plugins && wget --no-check-certificate http://updates.jenkins-ci.org/latest/git.hpi)

ADD https://raw.githubusercontent.com/MazLiz/DockerImage/master/entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENV JENKINS_HOME /jenkins

VOLUME /jenkins

# configure the container to run jenkins, mapping container port 8080 to that host port
EXPOSE 8080

#ENTRYPOINT  ["bin/bash", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/entrypoint.sh"]


