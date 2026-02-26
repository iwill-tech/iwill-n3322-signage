# IWILL N3322 Digital Signage - Installation Guide

## Overview

This guide explains how to install IWILL Digital Signage on N3322 mini PCs for customer deployments.

**Time required:** ~30 minutes per unit

---

## What You Need

- [ ] N3322 mini PC
- [ ] USB flash drive (8GB+)
- [ ] Keyboard (for initial setup)
- [ ] Monitor with HDMI cable
- [ ] Internet connection (ethernet recommended)
- [ ] IWILL Signage ISO file (`iwill-signage-22.04.5-amd64.iso`)

---

## Step 1: Create Bootable USB

### On Windows:

1. Download **Rufus** from https://rufus.ie
2. Insert USB drive
3. Open Rufus
4. Select the USB drive
5. Click **SELECT** → choose the ISO file
6. Click **START**
7. If prompted, select **Write in ISO Image mode**
8. Wait for completion (~5 minutes)

### On Mac/Linux:

```bash
# Find your USB device (be careful!)
lsblk  # Linux
diskutil list  # Mac

# Write ISO (replace /dev/sdX with your USB)
sudo dd if=iwill-signage-22.04.5-amd64.iso of=/dev/sdX bs=4M status=progress
```

---

## Step 2: Install Ubuntu

1. **Connect** keyboard, monitor, and ethernet to N3322
2. **Insert** the USB drive
3. **Power on** the N3322
4. **Press F7** repeatedly during boot to enter boot menu
5. **Select** the USB drive
6. **Choose** "IWILL Signage - Install"

### During Installation:

| Screen | Action |
|--------|--------|
| Language | Select English |
| Keyboard | Keep default |
| Updates | Select "Minimal installation" |
| Installation type | "Erase disk and install Ubuntu" |
| Timezone | Select customer's timezone |
| User setup | See below |

### User Setup:
- **Name:** admin
- **Computer name:** (leave as `iwilln3322ds1` or set customer name)
- **Username:** admin
- **Password:** [YOUR-PASSWORD]
- **☑️ Log in automatically**

7. Wait for installation (~10 minutes)
8. **Remove USB** when prompted
9. **Restart**

---

## Step 3: Configure Signage

After reboot, you'll see the Ubuntu desktop.

### Option A: Use Desktop Shortcut (Recommended)

1. **Double-click** "Setup Signage" icon on desktop
2. Wait for Xibo to download and install (~5 minutes)
3. Answer prompts:
   - **Kiosk mode?** → Y (for signage displays)
   - **Tailscale?** → Y (for remote management)
4. When Tailscale opens browser, log in with IWILL account
5. Done!

### Option B: Manual Setup

Open Terminal and run:
```bash
# Install Xibo
deploy-xibo.sh

# Or full setup wizard
setup-signage.sh
```

---

## Step 4: Verify Installation

1. Open Firefox
2. Go to `http://localhost`
3. Login with:
   - **Username:** `xibo_admin`
   - **Password:** `[YOUR-PASSWORD]`

You should see the Xibo CMS dashboard.

---

## Step 5: Connect to Tailscale (Remote Access)

If not done during setup:

```bash
sudo tailscale up
```

1. Copy the URL shown
2. Open on your phone/laptop
3. Log in with IWILL Tailscale account
4. Approve the device

**Note the Tailscale IP** (e.g., `100.x.x.x`) - this is how you'll access remotely.

---

## Quick Reference

| Item | Value |
|------|-------|
| Ubuntu login | `admin` / `[YOUR-PASSWORD]` |
| Xibo CMS URL | `http://localhost` or `http://<tailscale-ip>` |
| Xibo login | `xibo_admin` / `[YOUR-PASSWORD]` |
| SSH access | `ssh admin@<tailscale-ip>` |

### Useful Commands

```bash
# Check Xibo status
cd ~/xibo/xibo-docker-* && sudo docker compose ps

# Restart Xibo
sudo docker compose restart

# View logs
sudo docker compose logs -f

# Check Tailscale
tailscale status
```

---

## Troubleshooting

### Xibo not loading?
```bash
cd ~/xibo/xibo-docker-*
sudo docker compose down
sudo docker compose up -d
# Wait 1 minute, try again
```

### No internet after install?
```bash
# Check connection
ping 8.8.8.8

# If ethernet not working, try:
sudo dhclient -v
```

### Can't access remotely?
```bash
# Check Tailscale
tailscale status

# If disconnected:
sudo tailscale up
```

### Display not showing content?
1. Check Firefox is running in kiosk mode
2. Verify display is registered in Xibo CMS
3. Check display has assigned layout

---

## Handoff Checklist

Before leaving customer site:

- [ ] Ubuntu boots automatically
- [ ] Xibo CMS accessible at localhost
- [ ] Tailscale connected (note the IP)
- [ ] Kiosk mode working (if configured)
- [ ] Test content displays correctly
- [ ] Customer has Xibo login credentials
- [ ] Remote access verified from your phone

---

## Support

Internal: Contact tech team on Slack  
Documentation: See `XIBO-GUIDE.md` for CMS usage
