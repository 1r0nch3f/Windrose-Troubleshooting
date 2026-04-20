# I can't join any server

You're the one trying to connect, and nothing works regardless of which server you try.

## Quick checks

1. **Is Steam running and signed in?** Not in offline mode. Sign out and back in if unsure.
2. **Can you launch the game and reach the main menu?** If no, it's not a networking issue. Verify game files.
3. **Is the game up to date?** Check for updates through Steam.
4. **Try a different server or friend's session.** If one specific server fails but others work, see [specific user can't connect](specific-user-fails.md), just from the other side of the problem.

## Main causes

### Steam authentication is failing

Windrose authenticates via Steam's ticket system. If that's broken on your end, every connection attempt fails before you even reach the game server.

- Fully quit Steam (check the tray, it likes to stick around).
- Restart it and sign back in.
- Launch the game from your Steam library, not a shortcut.

### Your firewall is blocking outbound connections

Less common than inbound blocks, but possible. See [firewall checklist](../guides/firewall-checklist.md), specifically the outbound sections.

### VPN, proxy, or DNS-level filter in the way

- Disable any VPN temporarily.
- Disable any DNS-based ad blocker (Pi-hole, NextDNS, AdGuard Home).
- Try with your router's default DNS instead of a custom one.

### Running on Linux via Proton

Proton adds complexity. See [Linux client via Proton](../environments/linux-client-proton.md) for known issues and fixes.

### Your ISP is blocking game traffic

Rare, but some ISPs (especially mobile carriers) block outbound P2P or non-standard ports.

Test from a different network to confirm. A mobile hotspot from your phone works well for this, if the phone is on a different carrier than your home ISP.

### Backend services are down

Very rare, but if the Windrose backend is having an outage, nothing will work for anyone. Check the official Discord or Steam status page before assuming it's your problem.

## If none of the above helps

Gather your client log (see [gathering logs](../guides/gathering-logs.md)) and post in tech-support with the [support request template](../support-request-template.md) filled out.
