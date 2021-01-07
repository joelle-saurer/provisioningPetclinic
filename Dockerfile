FROM ubuntu

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openjdk-8-jdk wget
RUN java -version

RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat
RUN wget https://ftp.nluug.nl/internet/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-8.5.61/* /opt/tomcat/.

WORKDIR /opt/tomcat/webapps
ADD petclincics.war /opt/tomcat/apache-tomcat-8.5.61/webapps

EXPOSE 8080

CMD /opt/tomcat/apache-tomcat-8.5.61/bin/catalina.sh run

#FROM Ubuntu

#RUN apt-get update && apt-get -y install python3
#install python dependencies
#COPY . /pot/source-code

#CMD ["5"]

#ENTRYPOINT ["sleep"]
#ENTRYPOINT NAME_APP = /opt/source-code/app.py name run