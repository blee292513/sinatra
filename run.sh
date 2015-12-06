#/bin/bash

#STOP NGINX and REMOVE nginx_new.conf file
sudo service nginx stop
sudo rm -f nginx_new.conf

#INSTALL DOCKER
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install linux-image-extra-`uname -r`
sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo wget -qO- https://get.docker.com/ | sh
sudo service docker start

#PULL AND RUN sinatra app
sudo git clone https://github.com/blee292513/sinatra.git
cd sinatra
sudo docker build -t ruby-app .
sudo docker run --name ruby-app -d -p 4567:4567 ruby-app

#PULL AND RUN NGINX
sudo wget http://nginx.org/keys/nginx_signing.key
sudo cat nginx_signing.key | sudo apt-key add -
sudo docker pull nginx:latest
sudo apt-get install nginx

#ADD new file : nginx_new.conf
sudo touch ./nginx_new.conf
sudo chmod 777 *
sudo echo "worker_processes 1;" >> ./nginx_new.conf
sudo echo "events {" >> ./nginx_new.conf
sudo echo "worker_connections 1024;" >> ./nginx_new.conf
sudo echo "}" >> ./nginx_new.conf
sudo echo "http {" >> ./nginx_new.conf
sudo echo "upstream app {" >> ./nginx_new.conf
sudo echo "server 172.17.0.2:4567;" >> ./nginx_new.conf
sudo echo "}" >> ./nginx_new.conf
sudo echo "server {" >> ./nginx_new.conf
sudo echo "listen 4444;" >> ./nginx_new.conf
sudo echo "location /{" >> ./nginx_new.conf
sudo echo "proxy_pass http://app/;" >> ./nginx_new.conf
sudo echo "}" >> ./nginx_new.conf
sudo echo "}" >> ./nginx_new.conf
sudo echo "}" >> ./nginx_new.conf

#RUN nginx_container
sudo service nginx start
sudo docker run --name nginx_container -d -p 4444:4444 -v $(pwd)/nginx_new.conf:/etc/nginx/nginx.conf:ro --link ruby-app nginx

