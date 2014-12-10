# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# Jenkins 1.574
# git 1.9.1
# Nano 2.2.6-1ubuntu1

# extend the most recent long term support Ubuntu version
FROM ubuntu:14.04

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

# copy jenkins war file to the container
RUN curl -L http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war -o /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins

RUN java -jar /opt/jenkins.war &
RUN sleep 10s

ADD http://updates.jenkins-ci.org/download/plugins/buildresult-trigger /jenkins/plugins

# add plugin
# RUN mkdir /script
# ADD https://github.com/MazLiz/DockerImage/plugin_jenkins /script

# configure the container to run jenkins, mapping container port 8080 to that host port
EXPOSE 8080
#ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]

#install plugin (buildresult-trigger) jenkins
#CMD curl http://updates.jenkins-ci.org/download/plugins/buildresult-trigger/ > jenkins/plugins

