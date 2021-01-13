FROM ubuntu:latest
#install all the dependencies needed & update apt caches
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openjdk-8-jdk wget
RUN java -version

#install necessary pipeline tools
RUN apt-get -y install maven
RUN apt-get -y install git

EXPOSE 8086

ADD . /home/azureuser/Provisioning
CMD cd /home/azureuser/Provisioning; mvn tomcat7:run 

