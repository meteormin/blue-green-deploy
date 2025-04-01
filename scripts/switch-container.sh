#!/bin/bash

health_url="http://localhost:8080/health"

# Function to check container health
check_health() {
  local container_name=$1
  docker exec "$container_name" curl -f "$health_url" > /dev/null 2>&1
}

get_running_containers() {
  local container_name_pattern=$1
  local containers
  # Get list of containers matching the pattern
  containers=$(docker ps -a --filter "name=${container_name_pattern}" --format "{{.Names}}|{{.Status}}" | sort)
  # Separate running containers
  local running_containers=()
  IFS=$'\n'
  for container in $containers; do
    name=$(echo "$container" | awk -F'|' '{print $1}')
    status=$(echo "$container" | awk -F'|' '{print $2}')
    if [[ "$status" == *"Up"* ]]; then
      running_containers+=("$name")
    fi
  done
  unset IFS
  echo "${running_containers[@]}"
}

get_stopped_containers() {
  local container_name_pattern=$1
  local containers
  # Get list of containers matching the pattern
  containers=$(docker ps -a --filter "name=${container_name_pattern}" --format "{{.Names}}|{{.Status}}" | sort)
  # Separate stopped containers
  local stopped_containers=()
  IFS=$'\n'
  for container in $containers; do
    name=$(echo "$container" | awk -F'|' '{print $1}')
    status=$(echo "$container" | awk -F'|' '{print $2}')
    if [[ "$status" != *"Up"* ]]; then
      stopped_containers+=("$name")
    fi
  done
  unset IFS
  echo "${stopped_containers[@]}"
}

switch_container() {
  local delay=$1
  local container_name_pattern=$2
  shift 2
  local running_containers=("$@")
  IFS=' ' read -r -a running_containers_array <<< "${running_containers[0]}"

  local stopped_containers
  stopped_containers=$(get_stopped_containers "$container_name_pattern")
  IFS=' ' read -r -a stopped_containers_array <<< "$stopped_containers"

  echo "Running containers: ${running_containers_array[*]}"

  # If all containers are running, stop all but the first one
  if [ ${#running_containers_array[@]} -gt 1 ]; then
    for ((i=1; i<${#running_containers_array[@]}; i++)); do
      echo "Stopping container ${running_containers_array[$i]}"
      docker stop "${running_containers_array[$i]}"
    done
  fi

  # If only one container is running, start the next numbered container
  if [ ${#running_containers_array[@]} -eq 1 ]; then
    current_container="${running_containers_array[0]}"
    echo "Current container: $current_container"

    next_container="${stopped_containers_array[0]}"
    echo "Starting container $next_container"
    docker start "$next_container"

    # timeout in seconds
    timeout=300
    time=0
    # Wait for the new container to be healthy
    until check_health "$next_container"; do
      echo "Waiting for container $next_container to be healthy"
      sleep $delay

      time=$((time + delay))
      if [ $time -ge $timeout ]; then
        echo "Timeout waiting for container $next_container to be healthy"
        exit 1
      fi
    done

    # Stop the original container
    echo "Stopping container $current_container"
    docker stop "$current_container"
  fi
}

extract_suffix() {
  local container_name=$1
  echo "${container_name##*-}"
}

