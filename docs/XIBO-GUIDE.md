# Xibo CMS - User Guide

## What is Xibo?

Xibo is digital signage software. You create **Layouts** (screens with content), assign them to **Displays** (physical screens), and Xibo shows them automatically.

---

## Accessing Xibo

- **Local:** http://localhost (on the signage PC)
- **Remote:** http://<tailscale-ip> (from anywhere)
- **Login:** `xibo_admin` / `[YOUR-PASSWORD]`

---

## Key Concepts

| Term | Meaning |
|------|---------|
| **Layout** | A screen design with regions containing content |
| **Region** | An area on the layout (like a box) |
| **Widget** | Content type (image, video, text, clock, etc.) |
| **Playlist** | A sequence of content items |
| **Display** | A physical screen running Xibo Player |
| **Schedule** | When to show which layout |

---

## Quick Start: Create Your First Layout

### 1. Create a Layout

1. Go to **Design → Layouts**
2. Click **Add Layout**
3. Enter a name (e.g., "Welcome Screen")
4. Set resolution (1920x1080 for Full HD)
5. Click **Save**

### 2. Add a Region

1. Click on the layout to edit
2. Click **+ Region** in the toolbar
3. Draw a rectangle where you want content
4. Resize/position as needed

### 3. Add Content (Widgets)

1. Click on the region
2. Click **+ Widget**
3. Choose content type:

| Widget | Use For |
|--------|---------|
| **Image** | Photos, logos, backgrounds |
| **Video** | Video files |
| **Text** | Messages, announcements |
| **Clock** | Current time |
| **Webpage** | External websites |
| **Ticker** | Scrolling text/RSS |

4. Configure the widget
5. Set duration (how long to show)
6. Click **Save**

### 4. Publish Layout

1. Click **Publish** button
2. Layout is now ready to schedule

---

## Adding Content to Library

Before using images/videos, upload them:

1. Go to **Library → Media**
2. Click **Add Media**
3. Drag files or click to browse
4. Click **Upload**

Supported formats:
- **Images:** JPG, PNG, GIF
- **Videos:** MP4, WebM (H.264 codec recommended)

---

## Managing Displays

### Register a New Display

When Xibo Player first connects, it appears in:
**Displays → Displays** with status "Awaiting Approval"

1. Click on the display
2. Click **Authorise**
3. Set display name
4. Click **Save**

### Display Settings

| Setting | Recommendation |
|---------|----------------|
| Default Layout | Set a fallback layout |
| Interleave Default | Leave unchecked |
| Screenshot | Enable for remote monitoring |

---

## Scheduling Content

### Simple Schedule (Always On)

1. Go to **Schedule**
2. Click **Add Event**
3. Select layout
4. Select display(s)
5. Set:
   - **From:** Now
   - **To:** (leave empty for always)
6. Click **Save**

### Time-Based Schedule

Example: Show "Menu" layout only during lunch:

1. Add Event
2. Select "Menu" layout
3. Set:
   - **From:** 11:00
   - **To:** 14:00
   - **Repeat:** Daily
4. Save

### Priority

Higher priority events override lower ones:
- Priority 0 = lowest (default content)
- Priority 1+ = override content

---

## Common Tasks

### Change Background Color

1. Edit layout
2. Click layout properties (gear icon)
3. Set background color
4. Save

### Add Logo to Corner

1. Add small region in corner
2. Add Image widget
3. Upload/select logo
4. Set duration to match layout

### Scrolling Text Ticker

1. Add region at bottom
2. Add Ticker widget
3. Enter text or RSS feed URL
4. Set scroll speed
5. Set effect (marquee left)

### Show Current Date/Time

1. Add region
2. Add Clock widget
3. Choose format/style
4. Set timezone

### Display Webpage

1. Add region
2. Add Webpage widget
3. Enter URL
4. Enable/disable scrolling
5. Set refresh rate

---

## Multi-Screen Layouts

For N3322 with multiple monitors:

### Option 1: Display Groups

1. Create Display Group (**Displays → Display Groups**)
2. Add all monitors to group
3. Schedule to the group

### Option 2: Sync Group

For perfectly synchronized playback:
1. Set one display as "Lead"
2. Others as "Follower"
3. All show same content in sync

---

## Useful Tips

### Preview Before Publishing

Click **Preview** button to see how layout looks without publishing.

### Copy Layouts

Right-click layout → **Copy** to create variations quickly.

### Bulk Scheduling

Select multiple displays or display groups to schedule at once.

### Proof of Play

**Reporting → Proof of Play** shows what played and when.

### Remote Screenshots

Enable in display settings. View in **Displays** to see current screen.

---

## Troubleshooting

### Content Not Updating

1. Check schedule is correct
2. Force display refresh:
   - **Displays → [select] → Edit → Actions → Collect Now**

### Video Not Playing

- Convert to H.264 MP4
- Check file isn't corrupted
- Reduce resolution if hardware struggles

### Display Offline

Check on the signage PC:
```bash
# Is Docker running?
sudo docker compose ps

# Restart if needed
sudo docker compose restart
```

### Layout Shows Black

- Check region has content
- Verify widgets have duration > 0
- Publish the layout

---

## Support Resources

- **Xibo Manual:** https://xibo.org.uk/manual
- **Community:** https://community.xibo.org.uk
- **IWILL Support:** [internal contact]

---

## Quick Reference

| Action | Where |
|--------|-------|
| Create layout | Design → Layouts → Add |
| Upload media | Library → Media → Add |
| View displays | Displays → Displays |
| Schedule content | Schedule → Add Event |
| Check what's playing | Reporting → Proof of Play |
| See display screenshot | Displays → [display] → Screenshot |
