# Connection drops during gameplay

You connect successfully, play for a while, then get disconnected. This is a different class of problem from failed initial connections.

> This section is a stub. Contributions welcome.

## Common patterns

### Drops at consistent intervals

If disconnects happen on a regular cadence (every 5 minutes, every hour), suspect:

- A NAT session timeout on your router. Some routers age out UDP sessions aggressively.
- A keepalive failure between the client and server.
- A scheduled restart on the server side.

### Drops during high-activity moments

If disconnects correlate with combat, crowded areas, or world events, suspect:

- Bandwidth saturation. Run a speed test during the activity.
- CPU starvation on the server (check host CPU during the event).
- Packet loss from the ISP.

### Random, inconsistent drops

Hardest to diagnose. Likely:

- Flaky ISP connection.
- Wi-Fi issues (try wired for both host and client as a test).
- Something on the network competing for bandwidth.

## Things to check

- Server-side logs for the moment of disconnect. Was it logged as a clean disconnect, or did the server not see it coming?
- Your router's event log, if it has one.
- Whether other online services (web browsing, video calls) also hiccup at the same time.

## Get the logs

Both client and server logs around the time of disconnect are helpful. See [gathering logs](../guides/gathering-logs.md).
