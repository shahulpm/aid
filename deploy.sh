#!/bin/bash

# Define the base directory for your services
BASE_DIR="/c/Users/mshah/OneDrive/desktop/full-deploy"

# Array of services with their respective branches
declare -A SERVICES=(
  ["aid"]="main"
  ["cart"]="main"
  ["admin"]="main"
)

# Flag to track if any service was built
services_built=false

# Function to check for changes and build the service
build_service() {
  local service=$1
  local branch=$2
  local service_dir="$BASE_DIR/$service"
  local docker_tag="$service-service"

  cd "$service_dir" || { echo "Directory $service_dir not found"; exit 1; }

  # Fetch the latest changes
  git fetch origin "$branch"

  # Check for changes
  LOCAL_HASH=$(git rev-parse HEAD)
  REMOTE_HASH=$(git rev-parse origin/"$branch")

  if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "Changes detected in $service. Building and deploying..."

    # Pull the latest changes
    git pull origin "$branch"

    # Build the Docker image
    docker build -t "$docker_tag" .

    echo "$service built and tagged as $docker_tag."

    services_built=true
  else
    echo "No changes detected in $service. Skipping build."
  fi
}

# Iterate over each service and build if there are changes
for service in "${!SERVICES[@]}"; do
  build_service "$service" "${SERVICES[$service]}"
done

if [ "$services_built" = true ]; then
  cd "$BASE_DIR/compose" || { echo "Docker Compose directory not found"; exit 1; }
  docker compose down
  docker compose up -d
  echo "Docker Compose services updated successfully."
else
  echo "No services were built. Skipping Docker Compose update."
fi