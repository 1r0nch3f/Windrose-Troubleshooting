# Nobody can connect to my server

You're hosting, but none of your friends can get in. This is usually a network-level problem on your side.

## Quick checks (do these first)

1. **Is the server actually running and listening?** Check the logs for a successful startup message and confirm the game/server process is alive.
2. **Can you connect to your own server from the same machine?** If not, it's not a networking issue, it's a game-side problem. Skip to [error catalog](../errors/README.md).
3. **Restart the router.** Not glamorous, but fixes transient issues often enough to be worth trying before diving deeper.

## Main causes, in rough order of likelihood

### CGNAT on your ISP

If your ISP uses Carrier-Grade NAT, you share a public IP with many other customers and inbound connections don't reach you. Common with mobile broadband and increasingly common with fiber ISPs.

Check for CGNAT: see [CGNAT check](../guides/cgnat-check.md).

Workarounds: static/dedicated IP from your ISP, VPN with port forwarding, or a relay service like ZeroTier, Tailscale, or Radmin VPN.

### Port forwarding not set up or misconfigured

If you're behind a standard NAT (not CGNAT), your router needs to forward Windrose's ports to your machine.

See [port forwarding guide](../guides/port-forwarding.md).

### Firewall blocking the game

Windows Defender, third-party antivirus, or Linux firewalls (ufw, firewalld, iptables) can silently block incoming connections. See [firewall checklist](../guides/firewall-checklist.md).

### Double NAT

If you have a modem-router combo from your ISP plus your own router, you may be double-NATed. Port forwards need to be set up on both, or the outer device needs to be in bridge mode.

### Wrong listen address in dedicated server config

If you're running a dedicated server, check `P2pProxyAddress` in `ServerDescription.json`. The default `127.0.0.1` is correct for Docker setups where the proxy is internal. Changing this without understanding it can break connectivity.

## If none of the above helps

Collect the relevant logs (see [gathering logs](../guides/gathering-logs.md)) and post in tech-support using the [support request template](../support-request-template.md).
