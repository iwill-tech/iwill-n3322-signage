# Quick Start - Build Custom ISO

## Step 1: Build the Docker Image
Open PowerShell in the `iwill-signage-iso` folder and run:

```powershell
cd C:\Users\vasko\.openclaw\workspace\iwill-signage-iso
docker-compose build
```

This takes ~5 minutes.

## Step 2: Run the Build
```powershell
docker-compose up
```

This downloads Ubuntu and builds the custom ISO. Takes 30-60 minutes.

## Step 3: Get the ISO
The ISO file will be in:
```
C:\Users\vasko\.openclaw\workspace\iwill-signage-iso\output\
```

Filename: `iwill-signage-22.04.5-amd64.iso`

## Step 4: Flash to USB
Use Rufus:
1. Open Rufus
2. Select your USB drive
3. Select the ISO file
4. Click START

## Step 5: Install on N3322
1. Insert USB into N3322
2. Power on, press F7 for boot menu
3. Select USB
4. Choose "Install IWILL Signage (Automated)"
5. Walk away - it installs automatically

## After Install
- Boot automatically into signage mode
- Web interface: http://[IP]:8080
- SSH: admin/[YOUR-PASSWORD]
- Tailscale: Run `sudo tailscale up` to connect

## What Gets Installed
- Ubuntu Server 22.04.5
- Docker + Docker Compose
- Anthias (Screenly) digital signage
- Tailscale VPN
- OpenSSH server
- Auto-starts on boot
