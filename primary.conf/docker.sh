#!/bin/bash
# script to install docker

#sudo apt-get remove docker docker-engine docker.io

sudo apt-get update 
sudo apt-get install -y  \
  apt-transport-https    \
  ca-certificates        \
  curl                   \
  software-properties-common

CURL_RET_VALUEi=`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

APT_KEY_FINGERPRINT="9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"

FINGERPRINT_FOUND=`sudo apt-key fingerprint 0EBFCD88 | head -n 2 | tail -n 1 | awk '{print $1=$2=$3="";print}' | tail -n 1`

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce

#sudo groupadd docker
USERNAME=`cat /etc/passwd | grep akshit | cut -d':' -f1`
sudo usermod -aG docker $USERNAME

docker run hello-world

if [ $USER == "akshit" ]; then
  echo "disabling starting docker at boot"
  echo manual | sudo tee /etc/init/docker.override
  # sudo chkconfig docker on
fi

