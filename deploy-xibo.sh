#!/bin/bash
# IWILL N3322 Digital Signage - Xibo Deployment Script
# Usage: curl -sL http://your-server/deploy-xibo.sh | bash
# Or: ./deploy-xibo.sh

set -e

echo "========================================"
echo "  IWILL N3322 - Xibo CMS Deployment"
echo "========================================"

# Configuration
XIBO_DIR="$HOME/xibo"
MYSQL_PASSWORD="[AUTO-GENERATED]"
ADMIN_PASSWORD="[YOUR-PASSWORD]"  # Change this for production

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not installed. Run: sudo apt install docker.io docker-compose-v2 -y"
    exit 1
fi

# Create directory
mkdir -p "$XIBO_DIR"
cd "$XIBO_DIR"

# Download Xibo Docker
echo "[1/4] Downloading Xibo CMS..."
wget -q https://xibosignage.com/api/downloads/cms -O xibo-docker.tar.gz
tar -xzf xibo-docker.tar.gz
cd xibo-docker-*

# Configure
echo "[2/4] Configuring..."
cp config.env.template config.env
sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$MYSQL_PASSWORD/" config.env
sed -i "s/CMS_SERVER_NAME=.*/CMS_SERVER_NAME=$(hostname -I | awk '{print $1}')/" config.env

# Start containers
echo "[3/4] Starting Xibo (this takes ~2 minutes on first run)..."
sudo docker compose up -d

# Wait for MySQL to initialize
echo "[4/4] Waiting for database initialization..."
sleep 30

# Set admin password
echo "Setting admin password..."
sudo docker compose exec -T cms-web php /var/www/cms/bin/run.php user:password xibo_admin "$ADMIN_PASSWORD" 2>/dev/null || true

# Get IP address
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "========================================"
echo "  Xibo CMS Installation Complete!"
echo "========================================"
echo ""
echo "  URL:      http://$IP"
echo "  Username: xibo_admin"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo "  Manage:   cd $XIBO_DIR/xibo-docker-*"
echo "            sudo docker compose [up -d|down|logs]"
echo ""
echo "========================================"
