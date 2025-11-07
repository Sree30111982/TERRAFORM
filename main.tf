terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.6.0"
}

# Provider configuration for Windows
provider "docker" {
  # Connect to Docker using the Windows named pipe
  host = "npipe:////./pipe/docker_engine"
}

# Define port mapping depending on workspace
locals {
  port_map = {
    default = 9099
    DEV     = 9098
    PROD    = 9097
    UAT     = 9096
    }

     container_port = lookup(local.port_map, terraform.workspace, 9099)
}

# Pull the latest NGINX image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# Create and run a Docker container
resource "docker_container" "nginx" {
  name  = "vyshu_nginx_${terraform.workspace}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = local.container_port
  }
}
