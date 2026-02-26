#!/bin/bash
set -e

echo "========================================="
echo "  IWILL Signage ISO Builder v2.0"
echo "  (with Xibo CMS)"
echo "========================================="
echo ""

# Configuration
HOSTNAME="${HOSTNAME:-iwilln3322ds1}"
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-[YOUR-PASSWORD]}"
UBUNTU_VERSION="22.04.5"
UBUNTU_ISO="ubuntu-${UBUNTU_VERSION}-desktop-amd64.iso"
UBUNTU_URL="https://releases.ubuntu.com/${UBUNTU_VERSION}/${UBUNTU_ISO}"
OUTPUT_ISO="iwill-signage-${UBUNTU_VERSION}-amd64.iso"
WORKDIR="/build/work"
MOUNTDIR="/build/mount"
ISODIR="/build/iso"

echo "Configuration:"
echo "  Hostname: $HOSTNAME"
echo "  Username: $USERNAME"
echo "  Output: $OUTPUT_ISO"
echo ""

mkdir -p "$WORKDIR" "$MOUNTDIR" "$ISODIR" /build/output

# Download Ubuntu ISO if not exists
if [ ! -f "/build/output/$UBUNTU_ISO" ]; then
    echo "[1/6] Downloading Ubuntu Desktop ISO (~4.5GB)..."
    wget -q --show-progress "$UBUNTU_URL" -O "/build/output/$UBUNTU_ISO"
else
    echo "[1/6] Ubuntu ISO already downloaded"
fi

# Mount original ISO
echo "[2/6] Mounting original ISO..."
mount -o loop "/build/output/$UBUNTU_ISO" "$MOUNTDIR"

# Copy ISO contents
echo "[3/6] Copying ISO contents..."
rsync -a --exclude=/casper/filesystem.squashfs "$MOUNTDIR/" "$ISODIR/"

# Extract squashfs
echo "[4/6] Extracting and customizing system..."
unsquashfs -f -d "$WORKDIR/squashfs" "$MOUNTDIR/casper/filesystem.squashfs"

# Create chroot customization script
cat > "$WORKDIR/squashfs/tmp/customize.sh" << 'CHROOT_EOF'
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Enable universe repository
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y universe
apt-get update

# Install base tools
apt-get install -y \
    curl wget git vim htop net-tools \
    openssh-server x11-xserver-utils xinit \
    openbox unclutter firefox \
    --no-install-recommends

# Install Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker admin || true

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

# Create user
id -u admin &>/dev/null || useradd -m -s /bin/bash -G sudo admin
echo "admin:[YOUR-PASSWORD]" | chpasswd
echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin
chmod 440 /etc/sudoers.d/admin

# Set hostname
echo "iwilln3322ds1" > /etc/hostname

# Enable services
systemctl enable docker ssh

CHROOT_EOF

chmod +x "$WORKDIR/squashfs/tmp/customize.sh"

# Create Xibo deployment script inside ISO
cat > "$WORKDIR/squashfs/usr/local/bin/deploy-xibo.sh" << 'XIBO_EOF'
#!/bin/bash
# IWILL N3322 - Xibo CMS Deployment
set -e

echo "========================================"
echo "  IWILL N3322 - Xibo CMS Deployment"
echo "========================================"

XIBO_DIR="$HOME/xibo"
MYSQL_PASSWORD="[AUTO-GENERATED]"
ADMIN_PASSWORD="[YOUR-PASSWORD]"

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not installed!"
    exit 1
fi

mkdir -p "$XIBO_DIR"
cd "$XIBO_DIR"

echo "[1/4] Downloading Xibo CMS..."
wget -q https://xibosignage.com/api/downloads/cms -O xibo-docker.tar.gz
tar -xzf xibo-docker.tar.gz
cd xibo-docker-*

echo "[2/4] Configuring..."
cp config.env.template config.env
sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$MYSQL_PASSWORD/" config.env

echo "[3/4] Starting Xibo..."
sudo docker compose up -d

echo "[4/4] Waiting for initialization..."
sleep 45

sudo docker compose exec -T cms-web php /var/www/cms/bin/run.php user:password xibo_admin "$ADMIN_PASSWORD" 2>/dev/null || true

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "========================================"
echo "  COMPLETE!"
echo "  URL: http://$IP"
echo "  Login: xibo_admin / $ADMIN_PASSWORD"
echo "========================================"
XIBO_EOF

chmod +x "$WORKDIR/squashfs/usr/local/bin/deploy-xibo.sh"

# Create setup wizard
cat > "$WORKDIR/squashfs/usr/local/bin/setup-signage.sh" << 'SETUP_EOF'
#!/bin/bash
# IWILL N3322 - Complete Signage Setup
set -e

echo "========================================"
echo "  IWILL N3322 Signage Setup"
echo "========================================"

# Deploy Xibo
echo "[1/3] Installing Xibo CMS..."
/usr/local/bin/deploy-xibo.sh

# Kiosk mode
read -p "[2/3] Enable kiosk mode (auto-start browser)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
    cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
    mkdir -p ~/.config/autostart
    cat << EOF > ~/.config/autostart/kiosk.desktop
[Desktop Entry]
Type=Application
Name=Xibo Kiosk
Exec=firefox --kiosk http://localhost
EOF
    echo "Kiosk mode enabled."
fi

# Tailscale
read -p "[3/3] Connect to Tailscale? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo tailscale up
fi

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "  Xibo: http://$IP"
echo "  Login: xibo_admin / [YOUR-PASSWORD]"
echo "========================================"
SETUP_EOF

chmod +x "$WORKDIR/squashfs/usr/local/bin/setup-signage.sh"

# Desktop shortcut
mkdir -p "$WORKDIR/squashfs/etc/skel/Desktop"
cat > "$WORKDIR/squashfs/etc/skel/Desktop/Setup-Signage.desktop" << 'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Setup Signage
Comment=Configure IWILL Digital Signage
Exec=gnome-terminal -- /usr/local/bin/setup-signage.sh
Icon=utilities-terminal
Terminal=false
Categories=System;
DESKTOP_EOF

chmod +x "$WORKDIR/squashfs/etc/skel/Desktop/Setup-Signage.desktop"

# Chroot setup
mount --bind /dev "$WORKDIR/squashfs/dev"
mount --bind /proc "$WORKDIR/squashfs/proc"
mount --bind /sys "$WORKDIR/squashfs/sys"
mount --bind /run "$WORKDIR/squashfs/run"
rm -f "$WORKDIR/squashfs/etc/resolv.conf"
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > "$WORKDIR/squashfs/etc/resolv.conf"

chroot "$WORKDIR/squashfs" /bin/bash /tmp/customize.sh || echo "WARNING: Some customizations may have failed"

umount "$WORKDIR/squashfs/dev" 2>/dev/null || true
umount "$WORKDIR/squashfs/proc" 2>/dev/null || true
umount "$WORKDIR/squashfs/sys" 2>/dev/null || true
umount "$WORKDIR/squashfs/run" 2>/dev/null || true

# Build squashfs
echo "[5/6] Creating customized filesystem..."
mksquashfs "$WORKDIR/squashfs" "$ISODIR/casper/filesystem.squashfs" -comp xz -b 1M -noappend
printf $(du -sx --block-size=1 "$WORKDIR/squashfs" | cut -f1) > "$ISODIR/casper/filesystem.size"

# Build ISO
echo "[6/6] Building final ISO..."
cd "$ISODIR"

mkdir -p boot/grub
cat > boot/grub/grub.cfg << 'GRUB_EOF'
set timeout=10
set default=0

menuentry "IWILL Signage - Install" {
    linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}

menuentry "IWILL Signage - Live Session" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
GRUB_EOF

cp -r "$MOUNTDIR/EFI" "$ISODIR/" 2>/dev/null || true
cp -r "$MOUNTDIR/boot" "$ISODIR/" 2>/dev/null || true

xorriso -as mkisofs \
    -iso-level 3 -full-iso9660-filenames \
    -volid "IWILL-SIGNAGE" -J -joliet-long \
    -b boot/grub/i386-pc/eltorito.img \
    -c boot/grub/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot -e EFI/boot/bootx64.efi \
    -no-emul-boot -isohybrid-gpt-basdat \
    -output "/build/output/$OUTPUT_ISO" "$ISODIR"

cd /build/output
md5sum "$OUTPUT_ISO" > "${OUTPUT_ISO}.md5"
sha256sum "$OUTPUT_ISO" > "${OUTPUT_ISO}.sha256"

umount "$MOUNTDIR" 2>/dev/null || true
rm -rf "$WORKDIR" "$MOUNTDIR" "$ISODIR"

echo ""
echo "========================================="
echo "  BUILD COMPLETE!"
echo "========================================="
echo "  Output: /build/output/$OUTPUT_ISO"
echo "  Size: $(du -h /build/output/$OUTPUT_ISO | cut -f1)"
echo ""
echo "  Flash with Rufus, boot, install, then"
echo "  double-click 'Setup Signage' on desktop"
echo "========================================="
