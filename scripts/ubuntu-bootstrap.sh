#!/bin/bash
# AIOS Supercell - Ubuntu Bootstrap Script

set -e
LOG_FILE="/mnt/c/aios-supercell/logs/ubuntu-bootstrap-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== AIOS Ubuntu Bootstrap Started ==="

# Update system
log "Updating package lists..."
sudo apt update -qq

log "Upgrading packages..."
sudo apt upgrade -y -qq

# Install essential tools
log "Installing essential tools..."
sudo apt install -y -qq \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential

# Install Docker (will be used if Docker Desktop not preferred)
log "Installing Docker prerequisites..."
sudo apt install -y -qq apt-transport-https

log "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

log "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

log "Installing Docker Engine..."
sudo apt update -qq
sudo apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

log "Adding user to docker group..."
sudo usermod -aG docker $USER

# Create symbolic links to Windows AIOS directories
log "Creating symbolic links..."
ln -sf /mnt/c/aios-supercell ~/aios-supercell
ln -sf /mnt/c/Users/jesus/server ~/server

log "=== AIOS Ubuntu Bootstrap Complete ==="
log "Log saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Log out and back in for docker group to take effect"
echo "2. Test Docker: docker run hello-world"
echo "3. Install Docker Desktop on Windows for better integration"
