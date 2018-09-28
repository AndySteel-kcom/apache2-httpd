# Pull Images
FROM ubuntu:latest

# install required packages to make life easier using single line to 
# reduce number of intermediate containers needed by docker
RUN apt-get update && apt-get install -y \
  curl \
  net-tools \
  iputils-ping \
  vim \
  dos2unix

# Install latest Apache2 (v2.4.x)
RUN apt install -y apache2

# set working folder
WORKDIR /etc/apache2

# generate self-signed certificate for jamdev-docker which is docker container it'll be running on
RUN openssl genrsa -out server.key 2048 && \
    openssl req -new -key server.key -out server.csr \
        -subj "/C=UK/ST=East Yorkshire/L=Hull/O=KCOM/CN=jamdev-docker" && \
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# configure apache2 for proxy & reverse-proxy by installing required additional modules
# https://www.digitalocean.com/community/tutorials/how-to-use-apache-as-a-reverse-proxy-with-mod_proxy-on-ubuntu-16-04
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod headers
RUN a2enmod ssl

# copy our virtual host config to end of installed config file as opposed to trying to update it
COPY ./httpd.conf /etc/apache2/httpd.conf
RUN dos2unix /etc/apache2/httpd.conf
RUN cat /etc/apache2/httpd.conf >> /etc/apache2/sites-enabled/000-default.conf
RUN mkdir logs

# start apache2 service and run bash to keep container running
ENTRYPOINT service apache2 start && bash


# run this using docker create & run using this ...
#
# docker build -t kcom/apache2 . && docker run -it --rm --net=host apache2
#