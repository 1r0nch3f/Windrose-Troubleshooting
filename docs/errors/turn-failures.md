# TURN connection failures

## What you'll see in the log

```
R5LogIceProtocol: Warning: R5P2p::R5TurnTcpProtocol::OnTcpClientCreated
    Cannot connect to turn server <host>:3478; username '...'; password '******'.
    Status message ...
```

## What it means

Windrose uses STUN/TURN servers (the `coturn-*.windrose.support` hosts) as relays for peer-to-peer connections. When two players can't establish a direct P2P link, traffic falls back to these relays. The log shows attempts to connect to multiple TURN servers in different regions (EU, US, BR, KR, AU, RU).

A warning about one or two TURN servers failing while others succeed is normal. The client tries many regions and uses whichever responds.

## When it's actually a problem

- **All TURN servers fail.** Then peer-to-peer traffic has no fallback path and connection will fail.
- **Correlates with other symptoms.** If you're also seeing connection timeouts or failures, TURN unreachability may be part of the story.

## Likely causes when it is a problem

### Firewall blocking outbound to port 3478

TURN servers listen on port 3478. If your firewall, corporate network, or ISP blocks outbound UDP or TCP to 3478, you can't reach them.

Fix: allow outbound to 3478 UDP and TCP.

### DNS resolution failing

If `coturn-*.windrose.support` doesn't resolve, you won't reach any of them. Test with `nslookup` or `dig`.

### VPN or DNS filter mis-routing

VPNs and DNS filters sometimes block or mis-route specific domains. Try without them.

## Safe to ignore when

- A few TURN server warnings appear but the connection eventually succeeds
- You can see subsequent log lines showing successful P2P setup or ICE completion
