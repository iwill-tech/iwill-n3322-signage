# IWILL N3322 Digital Signage Documentation

## Guides

| Document | For | Description |
|----------|-----|-------------|
| [INSTALLATION-GUIDE.md](INSTALLATION-GUIDE.md) | Tech team | Step-by-step hardware setup |
| [XIBO-GUIDE.md](XIBO-GUIDE.md) | Everyone | How to use Xibo CMS |

## Quick Links

- **Xibo CMS:** http://localhost or http://<tailscale-ip>
- **Login:** `xibo_admin` / `[YOUR-PASSWORD]`
- **SSH:** `admin` / `[YOUR-PASSWORD]`

## Files in This Package

```
iwill-signage-iso/
├── docs/
│   ├── INSTALLATION-GUIDE.md  ← Hardware setup
│   └── XIBO-GUIDE.md          ← CMS usage
├── build-scripts/
│   └── build-iso.sh           ← ISO builder (internal)
├── output/
│   └── iwill-signage-*.iso    ← Bootable ISO
├── deploy-xibo.sh             ← Quick Xibo install
└── setup-signage.sh           ← Full setup wizard
```

## Support

Contact tech team for issues.
