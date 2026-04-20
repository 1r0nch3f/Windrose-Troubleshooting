# Scripts

Standalone diagnostic scripts you can run directly from PowerShell without
downloading or installing anything.

## Quick-Triage.ps1

A lightweight triage that checks the most common Windrose connection issues
in under 10 seconds. Use this first. If it can't pinpoint the cause, run the
full [Captain's Chest](https://github.com/1r0nch3f/Windrose-Captain-Chest)
toolkit for deeper diagnostics.

### What it checks

1. **Public IP and ISP detection** (via ipinfo.io), matched against the known
   culprit list (Spectrum, Xfinity, BT, Ziggo, and 20+ others).
2. **DNS resolution** of all four Windrose backend endpoints.
3. **TCP/443 reachability** to the three regional API gateways
   (EU/NA, CIS, KR/SEA).
4. **UDP/3478 reachability** using a real STUN binding request. This is the
   port Windrose uses for P2P signaling and is the most common point of
   failure on US cable ISPs.
5. **Latency** to the nearest gateway.

### What it outputs

- Color-coded terminal output
- A redacted log saved to your Desktop (`Windrose-Triage-YYYYMMDD-HHMMSS.log`)
- Optional clipboard copy for pasting in Discord

The IP is redacted to its first two octets, so the log is safe to share.

### Run it

One-liner, no download needed:

```powershell
irm https://raw.githubusercontent.com/1r0nch3f/Windrose-Troubleshooting/main/scripts/Quick-Triage.ps1 | iex
```

To also copy the log to your clipboard (useful for Discord), download and run
it instead of piping to `iex`:

```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/1r0nch3f/Windrose-Troubleshooting/main/scripts/Quick-Triage.ps1' -OutFile Quick-Triage.ps1
powershell -ExecutionPolicy Bypass -File .\Quick-Triage.ps1 -Clipboard
```

### Requirements

- Windows PowerShell 5.1 or newer (built into Windows 10/11)
- Outbound internet access for the checks to work

### Privacy

The log is designed to be safe to paste in a public Discord channel. It
contains only the minimum needed for someone to help diagnose your issue.

**What's in the log:**

- Your public IP, redacted to the first two octets (e.g. `147.253.xxx.xxx`)
- Your network's AS number (e.g. `AS30165`), without the provider name
- Your country code (e.g. `US`), no city or region
- DNS resolutions for the Windrose endpoints
- TCP and UDP test results
- The verdict and any recommended next steps

**What's NOT in the log:**

- Your full public IP
- Your ISP/provider name
- Your city, region, or any location finer than country
- Your computer name, username, or file paths
- MAC addresses, hardware info, or installed software
- Any information from your local network

If your ISP is on the [known-culprit list](https://github.com/1r0nch3f/Windrose-Captain-Chest/blob/main/CHANGELOG.md#130---2026-04-19)
(Spectrum, Xfinity, BT, Ziggo, etc.), the log will name that ISP in a
warning line, because knowing which one is on the list is the whole point
of that check. Otherwise, no ISP name appears anywhere.

No data is sent anywhere except the two calls needed for the checks
themselves (ipinfo.io for your public IP and the endpoint probes).

If you want even more control, the source is in this repo, review before
running.

### See also

- **[Captain's Chest](https://github.com/1r0nch3f/Windrose-Captain-Chest)**:
  the full diagnostic toolkit, which includes everything Quick Triage does
  plus system specs, port-forwarding checks, log salvage, redaction review,
  and detailed ISP fix instructions.
- **[Troubleshooting docs](../docs/)**: written guides for specific scenarios
  and error messages.
