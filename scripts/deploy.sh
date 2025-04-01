#!/bin/bash

BASEDIR=$(dirname "$0")

tag=$1

export TAG=$tag

imagePath="$BASEDIR/../.docker"
imageFilename=api-$tag.tar

echo "[Deploy] $env"
echo "tag=$tag"
echo "imageFilename=$imageFilename"

docker load -i "$imagePath/$imageFilename"

docker compose -f docker-compose.yml up -d --build

container_name_pattern="api"
service_name="api"

source "$BASEDIR/switch-container.sh"

running_containers=$(get_running_containers "$container_name_pattern")
IFS=' ' read -r -a running_containers_array <<< "$running_containers"

echo "Running containers: ${running_containers_array[*]}"

if [ ${#running_containers_array[@]} -eq 0 ]; then
  echo "No running containers found"

  docker compose -f docker-compose.yml \
    -f docker-compose.blue.yml \
    -f docker-compose.green.yml up -d --build

  running_containers=$(get_running_containers "$container_name_pattern")
  IFS=' ' read -r -a running_containers_array <<< "$running_containers"

  echo "Running containers: ${running_containers_array[*]}"
else
  stopped_containers=$(get_stopped_containers "$container_name_pattern")
  IFS=' ' read -r -a stopped_containers_array <<< "$stopped_containers"

  echo "Stopped containers: ${stopped_containers_array[*]}"

  if [ ${#stopped_containers_array[@]} -eq 1 ]; then
    first_stopped_container="${stopped_containers_array[0]}"
    container_color=$(extract_suffix "$first_stopped_container")
    echo "Update stopped container $first_stopped_container"

    docker compose -f docker-compose.yml \
    -f docker-compose.blue.yml \
    -f docker-compose.green.yml up -d --build --no-deps "$service_name-$container_color"
    docker stop "$first_stopped_container"
  fi
fi

echo "Switching containers"
switch_container 5 "$container_name_pattern" "${running_containers[@]}"

