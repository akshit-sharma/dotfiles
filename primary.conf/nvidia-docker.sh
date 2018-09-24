#!/bin/bash
# script to install docker

# docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
# sudo apt-get purge nvidia-docker

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
if [ "neon" == "`. /etc/os-release;echo $ID`" ]; then
  distribution=$(. /etc/os-release;echo ubuntu$VERSION_ID)
else 
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
fi
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd

docker run --runtime=nvidia --rm nvidia/cuda:9.0-devel nvidia-smi

