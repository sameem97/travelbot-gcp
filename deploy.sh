#!/bin/bash

# Interactive GCP Deployment Script for Travel Buddy

# Function to display colorful text
print_colored() {
  local color=$1
  local text=$2
  
  case $color in
    "green") echo -e "\033[0;32m$text\033[0m" ;;
    "blue") echo -e "\033[0;34m$text\033[0m" ;;
    "yellow") echo -e "\033[0;33m$text\033[0m" ;;
    "red") echo -e "\033[0;31m$text\033[0m" ;;
    *) echo "$text" ;;
  esac
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to display a section header
display_header() {
  echo ""
  print_colored "blue" "====================================================="
  print_colored "blue" "  $1"
  print_colored "blue" "====================================================="
  echo ""
}

# Check for required tools
check_prerequisites() {
  display_header "Checking Prerequisites"
  
  local missing_tools=()
  
  if ! command_exists docker; then
    missing_tools+=("docker")
  fi
  
  if ! command_exists gcloud; then
    missing_tools+=("gcloud")
  fi
  
  if [ ${#missing_tools[@]} -ne 0 ]; then
    print_colored "red" "Error: The following required tools are missing:"
    for tool in "${missing_tools[@]}"; do
      print_colored "red" "  - $tool"
    done
    print_colored "yellow" "Please install the missing tools and try again."
    exit 1
  fi
  
  print_colored "green" "✓ All required tools are installed."
}

# Collect configuration values
collect_config() {
  display_header "Configuration"
  
  # Project ID
  read -p "Enter your GCP Project ID: " PROJECT_ID
  while [ -z "$PROJECT_ID" ]; do
    print_colored "yellow" "Project ID cannot be empty."
    read -p "Enter your GCP Project ID: " PROJECT_ID
  done
  
  # Service name
  read -p "Enter the service name [travel-buddy]: " SERVICE_NAME
  SERVICE_NAME=${SERVICE_NAME:-travel-buddy}
  
  # Region
  read -p "Enter the deployment region [us-central1]: " REGION
  REGION=${REGION:-us-central1}
  
  # Docker image platform
  read -p "Build for specific platform? [linux/amd64]: " PLATFORM
  PLATFORM=${PLATFORM:-linux/amd64}
  
  # Allow unauthenticated
  read -p "Allow unauthenticated access? (y/n) [y]: " ALLOW_UNAUTH
  ALLOW_UNAUTH=${ALLOW_UNAUTH:-y}
  
  # Confirm settings
  echo ""
  print_colored "blue" "Configuration Summary:"
  echo "Project ID: $PROJECT_ID"
  echo "Service Name: $SERVICE_NAME"
  echo "Region: $REGION"
  echo "Platform: $PLATFORM"
  echo "Allow Unauthenticated: $ALLOW_UNAUTH"
  echo ""
  
  read -p "Is this configuration correct? (y/n) [y]: " CONFIRM
  CONFIRM=${CONFIRM:-y}
  
  if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    print_colored "yellow" "Configuration cancelled. Starting over..."
    collect_config
  fi
}

# Build Docker image
build_docker() {
  display_header "Building Docker Image"
  
  print_colored "yellow" "Building Docker image for $SERVICE_NAME..."
  
  if [[ -n "$PLATFORM" && "$PLATFORM" != "default" ]]; then
    docker build --platform $PLATFORM -t $SERVICE_NAME .
  else
    docker build -t $SERVICE_NAME .
  fi
  
  if [ $? -eq 0 ]; then
    print_colored "green" "✓ Docker image built successfully."
  else
    print_colored "red" "× Docker build failed."
    exit 1
  fi
}

# Tag Docker image
tag_docker() {
  display_header "Tagging Docker Image"
  
  local image_name="gcr.io/$PROJECT_ID/$SERVICE_NAME"
  print_colored "yellow" "Tagging Docker image as $image_name..."
  
  docker tag $SERVICE_NAME $image_name
  
  if [ $? -eq 0 ]; then
    print_colored "green" "✓ Docker image tagged successfully."
  else
    print_colored "red" "× Docker tag failed."
    exit 1
  fi
}

# Configure Docker for GCP
configure_docker() {
  display_header "Configuring Docker for GCP"
  
  print_colored "yellow" "Configuring Docker to use gcloud credentials..."
  
  gcloud auth configure-docker
  
  if [ $? -eq 0 ]; then
    print_colored "green" "✓ Docker configured for GCP."
  else
    print_colored "red" "× Docker configuration failed."
    exit 1
  fi
}

# Push Docker image to GCR
push_docker() {
  display_header "Pushing Docker Image to GCR"
  
  local image_name="gcr.io/$PROJECT_ID/$SERVICE_NAME"
  print_colored "yellow" "Pushing $image_name to Google Container Registry..."
  
  docker push $image_name
  
  if [ $? -eq 0 ]; then
    print_colored "green" "✓ Docker image pushed successfully."
  else
    print_colored "red" "× Failed to push Docker image."
    exit 1
  fi
}

# Enable required GCP services
enable_services() {
  display_header "Enabling Required GCP Services"
  
  print_colored "yellow" "Enabling Artifact Registry API..."
  gcloud services enable artifactregistry.googleapis.com
  
  print_colored "yellow" "Enabling Cloud Run API..."
  gcloud services enable run.googleapis.com
  
  print_colored "green" "✓ Required services enabled."
}

# Deploy to Cloud Run
deploy_to_cloud_run() {
  display_header "Deploying to Cloud Run"
  
  local image_name="gcr.io/$PROJECT_ID/$SERVICE_NAME"
  local auth_flag=""
  
  if [[ $ALLOW_UNAUTH == "y" || $ALLOW_UNAUTH == "Y" ]]; then
    auth_flag="--allow-unauthenticated"
  else
    auth_flag="--no-allow-unauthenticated"
  fi
  
  print_colored "yellow" "Deploying $SERVICE_NAME to Cloud Run in $REGION..."
  
  gcloud run deploy $SERVICE_NAME \
    --image $image_name \
    --region $REGION \
    --platform managed \
    $auth_flag
  
  if [ $? -eq 0 ]; then
    print_colored "green" "✓ Deployment successful!"
  else
    print_colored "red" "× Deployment failed."
    exit 1
  fi
}

# View Cloud Run logs
view_logs() {
  display_header "Viewing Cloud Run Logs"
  
  read -p "Would you like to view the logs? (y/n) [y]: " VIEW_LOGS
  VIEW_LOGS=${VIEW_LOGS:-y}
  
  if [[ $VIEW_LOGS == "y" || $VIEW_LOGS == "Y" ]]; then
    print_colored "yellow" "Fetching logs for $SERVICE_NAME..."
    
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" --limit=10
  fi
}

# Main menu
main_menu() {
  while true; do
    display_header "GCP Deployment Menu"
    
    echo "1) Run full deployment workflow"
    echo "2) Build and tag Docker image only"
    echo "3) Push to Container Registry only"
    echo "4) Deploy to Cloud Run only"
    echo "5) View Cloud Run logs"
    echo "6) Exit"
    echo ""
    
    read -p "Select an option [1]: " OPTION
    OPTION=${OPTION:-1}
    
    case $OPTION in
      1)
        check_prerequisites
        collect_config
        build_docker
        tag_docker
        configure_docker
        push_docker
        enable_services
        deploy_to_cloud_run
        view_logs
        ;;
      2)
        check_prerequisites
        collect_config
        build_docker
        tag_docker
        ;;
      3)
        check_prerequisites
        collect_config
        configure_docker
        push_docker
        ;;
      4)
        check_prerequisites
        collect_config
        enable_services
        deploy_to_cloud_run
        ;;
      5)
        check_prerequisites
        collect_config
        view_logs
        ;;
      6)
        print_colored "blue" "Exiting. Goodbye!"
        exit 0
        ;;
      *)
        print_colored "red" "Invalid option. Please try again."
        ;;
    esac
  done
}

# Display welcome message
display_header "Welcome to the GCP Deployment Script"
print_colored "green" "This script will help you deploy your application to Google Cloud Run."
echo ""

# Start the main menu
main_menu
