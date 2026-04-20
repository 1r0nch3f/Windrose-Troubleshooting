# Firewall checklist

Firewalls silently dropping traffic is a classic source of mysterious connection failures. This page walks through each common firewall and what to check.

## Windows Defender Firewall

### Quick check

1. Settings, Privacy & Security, Windows Security, Firewall & Network Protection
2. Click "Allow an app through firewall"
3. Look for Windrose and any related executables. Make sure they're checked for both Private and Public networks (or at least the network you're on).

### If Windrose isn't in the list

It should get added the first time you launch the game and Windows prompts you. If it didn't, click "Allow another app" and browse to the game executable.

### Testing if Defender is the problem

Temporarily turn off the firewall for your current network profile (Private or Public), try to connect. If it works with the firewall off, the firewall is what's blocking.

**Turn it back on afterward** and create a proper allow rule instead of leaving the firewall off.

## Third-party antivirus and security suites

Norton, McAfee, Kaspersky, Bitdefender, ESET, and similar suites include their own firewalls that run alongside or replace Windows Defender Firewall. Each has its own rules for allowing applications.

Common issues:

- The antivirus silently blocks outgoing game traffic as "suspicious"
- An "auto-sandbox" feature runs the game in isolation, breaking networking
- A "gaming mode" or "silent mode" doesn't actually help and may interfere

**Test**: temporarily disable the antivirus entirely (not just firewall). If that fixes it, look in the antivirus settings for a way to whitelist Windrose or its network traffic.

## Linux firewalls

### ufw (Ubuntu, Mint, Debian default)

Check current rules:
```bash
sudo ufw status verbose
```

If you're hosting, allow the game's ports. Check the official dedicated server docs for current port numbers, then:
```bash
sudo ufw allow <port>/udp
sudo ufw allow <port>/tcp
```

### firewalld (Fedora, RHEL, CentOS)

```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=<port>/udp --permanent
sudo firewall-cmd --reload
```

### iptables / nftables (raw)

```bash
sudo iptables -L -n
sudo nft list ruleset
```

If you don't already know how to write rules for these, use ufw or firewalld instead.

### Testing with the firewall fully off

On any Linux distro:
```bash
sudo ufw disable         # ufw
sudo systemctl stop firewalld   # firewalld
```

Try to connect. If it works, re-enable the firewall and add specific allow rules.

## Router-level firewalls

Some routers have a "SPI firewall" or similar feature that can interfere with game traffic, especially with aggressive defaults.

If your router has:

- "SPI" (Stateful Packet Inspection)
- "DoS protection"
- "Game acceleration" or "gaming mode"
- "QoS" rules targeting specific traffic types

Try turning them off one at a time to see if any unblocks the connection.

## Corporate / school / public networks

If you're on a network you don't control (work, school, coffee shop, shared housing), the network admin likely blocks game traffic outbound. You can't fix this locally. Options:

- Use a VPN that tunnels all traffic
- Use a different network (mobile hotspot)
- Ask the admin, if appropriate

## Inbound vs outbound

Understanding which direction is blocked helps narrow the fix:

- **Hosting, nobody can connect**: inbound is likely blocked. Router-level forwards plus host firewall rules.
- **Joining, you can't connect anywhere**: outbound is likely blocked. Usually the local firewall or antivirus on your machine.
- **Joining specific servers fails but others work**: probably not a firewall issue, more likely the destination side.

## If firewalls look clean but connection still fails

The firewall may not be the issue. Move on to [port forwarding](port-forwarding.md), [CGNAT](cgnat-check.md), or the [error catalog](../errors/README.md) depending on what the log shows.
