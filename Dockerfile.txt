FROM ubuntu:latest
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openjdk-8-jdk wget
RUN java -version

RUN apt-get -y install maven
RUN apt-get -y install git
ADD . /home/azureuser/Provisioning
CMD cd /home/azureuser/Provisioning; mvn tomcat7:run 
EXPOSE 8086
