FROM ubuntu:latest
#install all the dependencies needed & update apt caches
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openjdk-8-jdk wget
RUN java -version

#install necessary pipeline tools
RUN apt-get -y install maven && apt-get -y install git

#install tomcat
RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat

RUN wget https://ftp.nluug.nl/internet/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-8.5.61/* /opt/tomcat/.

#add war file to tomcat webapps
ADD . /home/azureuser/Provisioning
WORKDIR /home/azureuser/Provisioning
ADD petclinics.war /opt/tomcat/webapps

WORKDIR /opt/tomcat/webapps
CMD /opt/tomcat/bin/catalina.sh run 

EXPOSE 8080


