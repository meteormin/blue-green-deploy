#!/bin/bash

# set -x

REQUIREMENTS_FILE=$1

echo "Installing Developer Tools..."

if ! command -v brew &> /dev/null;then
  echo "Homebrew is not installed."
  echo "Installing Homebrew..."
  install_brew=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
  echo $install_brew

  echo "Homebrew installed successfully."
  echo "Try Install Cask"
  brew install cask
  echo "Cask installed successfully."
else
  echo "Homebrew is installed."
fi

echo "Installing brew packages..."
while read -r package; do
  if [[ -n "$package" && ! "$package" =~ ^\[.*\]$ ]]; then
    echo "*Installing ${package}..."
    brew install $package
  fi
done < <(awk '/^\[brew\]/ {flag=1; next} /^\[/ {flag=0} flag' ${REQUIREMENTS_FILE})

echo "Checking if Docker is installed..."
# Check if Docker is installed
if ! command -v docker &> /dev/null
then
  echo "*Docker is not installed."
  echo "*Installing Docker..."
  brew install --cask docker
else
    echo "*Docker is installed."
fi

exit 0;
