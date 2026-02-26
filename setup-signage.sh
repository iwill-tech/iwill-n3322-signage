#!/bin/bash
# IWILL N3322 - Complete Signage Setup
# Run after fresh ISO install to configure everything

set -e

echo "========================================"
echo "  IWILL N3322 Signage Setup"
echo "========================================"

# Get device info
IP=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)

# 1. Deploy Xibo
echo ""
echo "[Step 1] Installing Xibo CMS..."
curl -sL https://raw.githubusercontent.com/iwill-bg/signage/main/deploy-xibo.sh | bash

# 2. Configure auto-login and kiosk mode (optional)
read -p "Enable kiosk mode with auto-start browser? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Setting up kiosk mode..."
    
    # Auto-login
    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
    cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF

    # Start browser on login
    mkdir -p ~/.config/autostart
    cat << EOF > ~/.config/autostart/kiosk.desktop
[Desktop Entry]
Type=Application
Name=Xibo Kiosk
Exec=firefox --kiosk http://localhost
EOF

    echo "Kiosk mode configured. Reboot to activate."
fi

# 3. Configure Tailscale (optional)
read -p "Connect to Tailscale for remote management? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo tailscale up
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "  Xibo CMS: http://$IP"
echo "  Login:    xibo_admin / [YOUR-PASSWORD]"
echo ""
echo "  Next steps:"
echo "  1. Open Xibo in browser"
echo "  2. Add displays and layouts"
echo "  3. Configure your content"
echo ""
