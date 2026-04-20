# A specific user can't connect (but others can)

Most users can join your server fine, but one or two consistently fail. This almost always means the problem is on the affected user's side, not yours.

## What the server log usually shows

Look for lines like:
```
Error: Unexpected BL disconnect. AccountId <id>. BLPlayerSessionId '<session>'
```

This error means the backend authentication handshake failed for that specific user. See [BL disconnect errors](../errors/bl-disconnect.md) for a deeper dive.

## Things the affected user should check

### 1. Steam is running and logged in

Windrose uses Steam's authentication ticket system. If the user's Steam client is offline, signed out, or in a weird state, the ticket their game generates will be rejected by the backend.

- Fully quit and restart Steam.
- Confirm they're signed in (not in offline mode).
- Try launching the game through Steam, not from a desktop shortcut.

### 2. Game is up to date and files are intact

- Verify integrity of game files through Steam.
- Make sure their version matches the host's version. Mid-patch mismatches cause strange auth failures.

### 3. No VPN, proxy, or network-filtering software

VPNs, corporate proxies, Pi-holes with aggressive blocklists, and similar tools can interfere with the Steam auth backend (`r5coopapigateway-*.windrose.support`). Temporarily disable them to test.

### 4. They're not on Linux/Proton hitting a known quirk

If the affected user is running the game on Linux via Proton, there are a few known issues. See [Linux client via Proton](../environments/linux-client-proton.md).

### 5. Their own firewall

The user's local firewall may be blocking outbound traffic for the game. See [firewall checklist](../guides/firewall-checklist.md), focusing on the outbound section.

### 6. Their ISP or router is blocking P2P traffic

Some ISPs block non-standard ports or peer-to-peer protocols. If this user is on a different ISP from the rest of your group, that's a clue. They may need to test from a different network (mobile hotspot is a quick way to rule this in or out).

## What the host should check

Almost nothing on your side matters if others are connecting fine. But worth confirming:

- Your server version matches what the user has.
- You haven't hit your configured `MaxPlayerCount`.
- There's no password mismatch if the server is password-protected.

## Get their logs

The most useful thing is the **failing user's client-side R5.log**, not yours. See [gathering logs](../guides/gathering-logs.md) for where to find it on each platform.
