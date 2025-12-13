terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  region = var.region
}

# 1. Generate a random Project ID (Project IDs must be globally unique)
resource "random_id" "project_suffix" {
  byte_length = 4
}

# 2. Create the Project
resource "google_project" "n8n_project" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
}

# 3. Enable the Compute Engine API (Required to create VMs)
resource "google_project_service" "compute_api" {
  project = google_project.n8n_project.project_id
  service = "compute.googleapis.com"
  
  # Wait for the API to be fully enabled before moving on
  disable_on_destroy = false
}

# 4. Firewall Rule - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  project = google_project.n8n_project.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["n8n-server"]

  depends_on = [google_project_service.compute_api]
}

# 5. The Free Tier VM Instance
resource "google_compute_instance" "n8n_server" {
  name         = "n8n-server"
  project      = google_project.n8n_project.project_id
  machine_type = "e2-micro"      # Free Tier eligible
  zone         = var.zone

  tags = ["n8n-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30                 # Max Free Tier limit
      type  = "pd-standard"      # Must be Standard, not SSD
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral public IP
    }
  }

  # Ensure API is enabled before creating VM
  depends_on = [google_project_service.compute_api]

  # 6. Startup Script: Swap Memory + Docker + Compose
  metadata_startup_script = <<-EOT
    #!/bin/bash
    
    # Log everything to a file for debugging
    exec > >(tee -a /var/log/startup-script.log)
    exec 2>&1
    
    echo "=== Startup script started at $(date) ==="

    # --- A. Setup Swap Memory (CRITICAL for e2-micro 1GB RAM) ---
    if [ ! -f /swapfile ]; then
      echo "Creating swap file..."
      fallocate -l 2G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' >> /etc/fstab
      # Reduce swappiness to prefer RAM
      sysctl vm.swappiness=10
      echo 'vm.swappiness=10' >> /etc/sysctl.conf
    fi

    # --- B. Install Docker & Compose ---
    echo "Installing Docker..."
    export DEBIAN_FRONTEND=noninteractive
    
    # Install prerequisites
    echo "Installing prerequisites..."
    apt-get update -y || { echo "apt-get update failed"; exit 1; }
    apt-get install -y ca-certificates curl gnupg lsb-release || { echo "Failed to install prerequisites"; exit 1; }
    
    # Add Docker's official GPG key
    echo "Adding Docker GPG key..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg || { echo "Failed to add Docker GPG key"; exit 1; }
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up Docker repository
    echo "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Failed to set up Docker repo"; exit 1; }
    
    # Install Docker Engine and Docker Compose plugin
    echo "Installing Docker packages..."
    apt-get update -y || { echo "apt-get update after adding repo failed"; exit 1; }
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || { echo "Failed to install Docker packages"; exit 1; }
    
    echo "Docker installation complete. Versions:"
    docker --version || echo "ERROR: docker command not found!"
    docker compose version || echo "ERROR: docker compose not found!"
    
    # Docker should already be running, but ensure it's enabled
    echo "Starting Docker service..."
    systemctl enable docker || echo "Failed to enable docker"
    systemctl start docker || echo "Failed to start docker"
    systemctl status docker || echo "Docker status check failed"
    
    # Wait for Docker to be ready
    echo "Waiting for Docker to be ready..."
    retries=0
    max_retries=30
    until docker ps > /dev/null 2>&1; do
      retries=$((retries + 1))
      if [ $retries -gt $max_retries ]; then
        echo "ERROR: Docker failed to start after $max_retries attempts"
        exit 1
      fi
      echo "Docker not ready yet, waiting... (attempt $retries/$max_retries)"
      sleep 2
    done
    echo "Docker is ready!"
    
    # --- C. Setup Directory ---
    mkdir -p /home/ubuntu/n8n
    cd /home/ubuntu/n8n

    # --- D. Write Docker Compose File ---
    echo "Writing docker-compose.yml..."
    cat > docker-compose.yml <<'COMPOSE_EOF'
${local.docker_compose_content}
COMPOSE_EOF
    
    echo "Verifying docker-compose.yml was created:"
    ls -la docker-compose.yml
    echo "First few lines of docker-compose.yml:"
    head -20 docker-compose.yml

    # --- E. Write Env File ---
    echo "Writing .env file with tunnel token..."
    cat > .env <<ENVEOF
TUNNEL_TOKEN=${var.tunnel_token}
ENVEOF
    
    # Verify env file was created
    echo "Verifying .env file contents:"
    echo "TUNNEL_TOKEN=<redacted>" # Don't log the actual token
    ls -la .env

    # --- F. Fix Permissions ---
    echo "Setting permissions..."
    # Create local-files directory and give ownership to UID 1000 (node user)
    mkdir -p local-files
    chown -R 1000:1000 local-files
    chown -R ubuntu:ubuntu /home/ubuntu/n8n

    # --- G. Run the App ---
    echo "Starting Containers..."
    echo "Current directory: $(pwd)"
    echo "Files in directory:"
    ls -la
    
    docker compose up -d
    
    # Wait for containers to start
    echo "Waiting for containers to start..."
    sleep 20
    
    # Log container status
    echo "=== Container status ==="
    docker ps -a
    
    echo ""
    echo "=== Checking individual containers ==="
    
    # Check postgres
    if docker ps | grep -q "n8n-postgres"; then
      echo "✓ PostgreSQL container is running"
    else
      echo "✗ PostgreSQL container failed"
      docker logs n8n-postgres 2>&1 | tail -20
    fi
    
    # Check n8n
    if docker ps | grep -q "n8n"; then
      echo "✓ n8n container is running"
    else
      echo "✗ n8n container failed"
      docker logs n8n 2>&1 | tail -20
    fi
    
    # Check cloudflare tunnel
    if docker ps | grep -q "cloudflare-tunnel"; then
      echo "✓ Cloudflare tunnel is running"
      echo "Tunnel logs (last 10 lines):"
      docker logs cloudflare-tunnel 2>&1 | tail -10
    else
      echo "✗ Cloudflare tunnel failed"
      docker logs cloudflare-tunnel 2>&1 | tail -20
    fi
    
    echo ""
    echo "=== Startup script completed at $(date) ==="
    echo "You can view this log at: /var/log/startup-script.log"
  EOT
}

# 7. Read Docker Compose template and substitute variables
locals {
  docker_compose_content = templatefile("${path.module}/docker-compose.yml.tpl", {
    postgres_password = var.postgres_password
    domain            = var.domain
    timezone          = var.timezone
  })
}

# 8. Output the IP address and other info
output "instance_ip" {
  value       = google_compute_instance.n8n_server.network_interface.0.access_config.0.nat_ip
  description = "The external IP address of the n8n server"
}

output "vm_external_ip" {
  value       = google_compute_instance.n8n_server.network_interface.0.access_config.0.nat_ip
  description = "Alias for instance_ip (used by deployment scripts)"
}

output "project_id" {
  value       = google_project.n8n_project.project_id
  description = "The GCP project ID"
}

output "domain" {
  value       = var.domain
  description = "The domain configured for n8n"
}