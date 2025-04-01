#!/bin/bash
# author : meteormin
# date : 2024-02-05
# supported OS : macOS, Linux
# description : install dev tools

BASE_DIR=$(dirname "$0")

# First check OS.
OS="$(uname)"
if [[ "${OS}" == "Linux" ]]
then
  ON_LINUX=1
elif [[ "${OS}" == "Darwin" ]]
then
  ON_MACOS=1
else
  echo "Not supported OS: ${OS}"
  exit 1
fi

if [[ -n "${ON_MACOS-}" ]]
then
  . ./bin/dev-tools-mac "$BASE_DIR/packages"
  exit 0
fi

if [[ -n "${ON_LINUX-}" ]]
then
  . ./bin/dev-tools-linux "$BASE_DIR/packages"
  exit 0
fi

exit 1
