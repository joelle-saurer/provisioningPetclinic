FROM tomcat:8
LABEL maintainer=”joelle.saurer@devoteam.com

ADD petclinics.war /usr/local/tomcat/webapps/

EXPOSE 8086

CMD /usr/local/tomcat/bin/catalina.sh start



# FROM ubuntu

# RUN apt-get update && apt-get -y upgrade
# RUN apt-get -y install openjdk-8-jdk wget
# RUN java -version

# RUN mkdir /opt/source-code/
# COPY petclinics.war /opt/source-code

# RUN mkdir /opt/tomcat/
# WORKDIR /opt/tomcat

# RUN wget https://ftp.nluug.nl/internet/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
# RUN tar xvfz apache*.tar.gz
# RUN mv apache-tomcat-8.5.61/* /opt/tomcat/.

# WORKDIR /opt/source-code
# ADD petclinics.war /opt/tomcat/webapps

# WORKDIR /opt/tomcat/webapps

# CMD /opt/tomcat/bin/catalina.sh start

