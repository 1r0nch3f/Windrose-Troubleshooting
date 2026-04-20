# Am I behind CGNAT?

Carrier-Grade NAT (CGNAT) is when your ISP puts you behind a shared public IP along with many other customers. You can browse the web fine, but inbound connections can't reach you, because the ISP doesn't know which customer a given incoming packet is for.

If you're behind CGNAT and trying to host, port forwarding on your router won't help. The block is upstream of you.

## Quick check: compare IPs

1. Look at your router's WAN IP. Log in to the router admin page and find "WAN," "Internet," or "Status." Note the IP shown.
2. Look at your public IP from the outside. Visit [whatismyip.com](https://www.whatismyip.com/) or similar from a device on the same network.

- **If they match**: you have a real public IP. Not CGNAT.
- **If they differ**: your router has a private-range IP (like 100.64.x.x) while the outside world sees a different one. That's CGNAT (or a similar shared-IP arrangement).

## Shared-IP ranges to watch for

CGNAT typically uses the `100.64.0.0/10` range (addresses `100.64.x.x` through `100.127.x.x`). If your router's WAN IP is in that range, you're definitely behind CGNAT.

Other private ranges on your WAN (`10.x`, `192.168.x`, `172.16-31.x`) mean you're either behind your own double-NAT or behind the ISP's shared infrastructure. Either way, the symptom for hosting is similar.

## Which ISPs do this?

Most mobile carriers (including 4G/5G home internet). Increasingly common with fiber providers. Cable ISPs vary by region.

Rule of thumb: if your internet is wireless in any form (mobile, fixed wireless, satellite), assume CGNAT until you confirm otherwise.

## If you are behind CGNAT, what are the options?

### Ask your ISP for a dedicated public IP

Some ISPs offer this for free on request. Others charge a small monthly fee. Some refuse. Worth a phone call before doing anything else.

### Use a VPN with port forwarding

Commercial VPNs that offer port forwarding give you a reachable public endpoint on their server that tunnels to you. Examples of providers that support port forwarding (this changes over time, check current status):

- Mullvad (historically offered port forwarding, has changed policy, check current state)
- AirVPN
- Private Internet Access
- OVPN.com

You rent a port on their server, set up the VPN on your host machine, and your friends connect to the VPN's public endpoint which routes to you.

### Use a peer-to-peer VPN / overlay network

These create a private network between you and your friends, bypassing CGNAT entirely. Free or low-cost options:

- **Tailscale**, easy to set up, uses WireGuard
- **ZeroTier**, similar concept, works well for game servers
- **Hamachi**, older and commercial, still works
- **Radmin VPN**, free, popular for gaming

Everyone installs the tool, joins the same network, and the game treats each other's addresses as local.

Downside: each friend needs to install the tool and join your network.

### Relay / tunnel services

Services like Playit.gg explicitly cater to game hosting behind CGNAT. They act as a relay, giving you a public endpoint.

### Move the server to a cloud VPS

If you're serious about hosting, a small cloud VPS (DigitalOcean, Hetzner, Linode, etc.) has a real public IP by default. A few dollars a month.

For Windrose specifically, this works best with the [dedicated server](../environments/dedicated-server-windows.md), since you don't need to be physically at the machine to play.

## What CGNAT does NOT cause

If you can connect to other servers from your network, CGNAT on your end is not the issue. CGNAT only blocks **inbound** connections, not outbound. If outbound is failing too, look elsewhere (firewall, DNS, ISP filtering of specific protocols).
