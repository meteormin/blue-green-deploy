#!/bin/bash

# set -x

REQUIREMENTS_FILE=$1

echo "Installing Developer Tools..."

if command -v apt &> /dev/null;then
  echo "Installing apt packages..."
  sudo apt-get update -y
  while read -r package; do
    if [[ -n "$package" && ! "$package" =~ ^\[.*\]$ ]]; then
      echo "*Installing ${package}..."
      sudo apt-get install -y $package
    fi
  done < <(awk '/^\[apt\]/ {flag=1; next} /^\[/ {flag=0} flag' ${REQUIREMENTS_FILE})
fi

echo "Checking if Docker is installed..."
# Check if Docker is installed
if ! command -v docker &> /dev/null
then
  echo "*Docker is not installed."
  echo "*Installing Docker..."
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo docker run hello-world
else
  echo "*Docker is installed."
fi

exit 0;
