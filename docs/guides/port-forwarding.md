# Port forwarding

If you're hosting and your router is the default "block incoming, allow outgoing" setup, your friends can't reach your machine until you forward the right ports to it.

## Before you start

1. **Confirm you're not behind CGNAT first.** If your ISP uses CGNAT, port forwarding on your router won't help, because the block is upstream of you. See [CGNAT check](cgnat-check.md) first.
2. **Know your machine's local IP.** On Windows, `ipconfig` in Command Prompt. On Linux, `ip a`. Usually something like `192.168.1.x` or `10.0.0.x`. You'll forward ports to this IP.
3. **Ideally give the host a static local IP** or a DHCP reservation in your router, so the forward doesn't break when the IP changes.

## UPnP, the easy path

If your router has UPnP enabled (most do by default) and Windrose supports automatic port mapping via UPnP, the game may set up forwards automatically without you configuring anything.

UPnP pros: no config needed, handles the ports itself.
UPnP cons: some routers have buggy UPnP implementations; some networks disable it for security.

**Try with UPnP first.** If that works, you're done. If it doesn't, move to manual forwarding.

## Manual port forwarding

Windrose's specific port requirements vary by version. Check the official dedicated server guide at playwindrose.com for the current port list.

In general you'll be forwarding a mix of UDP and TCP ports. The game docs will specify exactly which.

To set up a manual forward:

1. Log in to your router's admin interface (usually `192.168.1.1` or `192.168.0.1` in a browser)
2. Find the port forwarding section (names vary: "Port Forwarding," "Virtual Server," "NAT Forwarding")
3. Add a new rule:
   - External port: the game's port
   - Internal port: same port (usually)
   - Internal IP: your host machine's local IP
   - Protocol: UDP, TCP, or both per the game's docs

After saving, restart the router if the rule doesn't seem to take effect.

## Testing

The easiest way to confirm forwards are working: have a friend try to connect. If they succeed, the forward is good.

To test more precisely, you can use an external port-checking tool. Run a listener on the host (netcat, or have the game/server running) and check from outside your network whether the port appears open.

## Common problems

### Double NAT

If your ISP provided a modem-router combo and you added your own router behind it, you have two NAT layers. Port forwards on the inner router don't help until the outer device either forwards to the inner router or is put in bridge mode.

Check by looking at your WAN IP on the inner router. If it's a private-range IP (10.x, 172.16-31.x, or 192.168.x), you're double-NATed.

### Forwarding to the wrong IP

If the host machine's IP changed since you set up the forward (DHCP gave it a new one), the forward now points nowhere. Set up a DHCP reservation in your router so the host always gets the same IP.

### Router has a "gaming mode" that clashes

Some consumer routers have features like "gaming mode," "QoS for gaming," or "DMZ" that can interfere with manual port forwards. If things aren't working, disable those extra features and test with just the manual forward.

### Firewall blocking after the port makes it through

Port forwarding gets traffic to your machine. Your local firewall then decides whether to accept it. If the router forward is correct but connections still fail, check the local firewall. See [firewall checklist](firewall-checklist.md).
