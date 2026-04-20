# Glossary

Networking and Windrose-specific terms that show up in this repo and in logs.

## Networking

**NAT (Network Address Translation)**: How your router lets multiple devices share one public IP. Devices behind NAT can initiate outbound connections; incoming connections from outside don't automatically reach them without a port forward.

**CGNAT (Carrier-Grade NAT)**: NAT at the ISP level. Your router is behind the ISP's NAT, so even with port forwards on your own router, inbound connections can't reach you. See [CGNAT check](guides/cgnat-check.md).

**Port forwarding**: A router rule that says "traffic arriving at port X from the internet should go to device Y on my internal network at port Z." Required for hosting when not using UPnP.

**UPnP (Universal Plug and Play)**: A protocol that lets applications ask the router to set up port forwards automatically. Convenient but not universally reliable.

**Double NAT**: When you have two layers of NAT, usually because your ISP's modem-router combo has NAT and you added your own router behind it. Port forwards need to be handled at both layers.

**STUN**: A lightweight protocol that helps two peers discover each other's public IP and ports so they can try to connect directly.

**TURN**: A heavier protocol that relays traffic between peers when a direct connection isn't possible. Windrose uses `coturn-*.windrose.support` as TURN servers.

**ICE**: The framework that combines STUN, TURN, and direct connection attempts to figure out the best way for two peers to talk.

**P2P (peer-to-peer)**: A connection model where two clients talk to each other directly instead of through a central server.

**Firewall**: Software or hardware that filters network traffic based on rules. Can block traffic you want if misconfigured.

**MTU (Maximum Transmission Unit)**: The largest size of a single network packet. MTU mismatches between your network and your ISP can cause strange connection issues, though it's rarely the cause of Windrose problems.

## Game-specific

**BL (Backend Link)**: Windrose's term for the persistent connection between a player's client and the backend session manager. Has to be fully established before a player enters the game.

**BLSessionId**: An ID for a particular backend session.

**BLPlayerSessionId**: An ID for a specific player within a backend session.

**PlayerController**: Unreal Engine's term for the object that represents a player. In Windrose, a player isn't fully "in" the game until their PlayerController is created. Many connection errors happen before this step.

**DataKeeper**: Internal system that tracks state about players (both client and server side). Many log messages about connection issues come from `R5DataKeeper*` components.

**P2pProxy**: A local proxy process that handles P2P connection setup. The `P2pProxyAddress` setting in server config refers to this; `127.0.0.1` is usually correct.

**Invite code**: The alphanumeric code players use to find a server. Set via `INVITE_CODE` env var or `InviteCode` in `ServerDescription.json`.

**Island / IslandId**: Windrose's world identifier. Each world has a unique IslandId.

## Tools and ecosystem

**Steamworks**: Steam's SDK for game integration, including authentication tickets. Windrose uses this for player identity.

**EOS (Epic Online Services)**: An alternative online services SDK. Windrose includes the EOS plugin but currently skips it by configuration, relying on Steam instead.

**gRPC**: An RPC (remote procedure call) framework used internally by Windrose for some server-client communication. When you see gRPC-related errors, it's usually in this internal RPC channel.

**Proton**: Valve's Wine-based compatibility layer for running Windows games on Linux via Steam.

**Wine**: An open-source compatibility layer that runs Windows applications on Linux, macOS, and BSD. Can be used directly (not via Steam/Proton) for running the Windrose dedicated server on Linux.

**SteamCMD**: Steam's command-line client, used for installing dedicated servers on headless machines without the Steam GUI.

**Podman**: An alternative to Docker for running containers. Compatible with most Docker images.
