# Unexpected BL disconnect

## What you'll see in the log

On the **server side** (whether self-hosted or dedicated):

```
Error: Unexpected BL disconnect. AccountId <hex-id>. BLPlayerSessionId '<session-id>'
```

Often followed by:

```
Disconnect account. PlayerController was not found. AccountId <hex-id>. Reason 'BL disconnected'
```

The callstack will point into `R5DataKeeperForServer.cpp`, around the `OnAccountBLDisconnected` handler.

## What it means

"BL" stands for Backend Link. It's the persistent connection between the player's game client and the server's backend session manager. Before a player can actually spawn in, their BL connection has to be established and verified.

This error means the BL connection dropped unexpectedly **before** the player was fully added to the game. The tell-tale detail is `PlayerController was not found`, meaning the server was still in the setup phase when the disconnect happened.

In short: the player's authentication handshake failed partway through.

## What side is the problem on?

Almost always the **connecting player's** side, not the host's.

The host's server just logs what it observed (the handshake never completed). The actual failure is happening in the connecting client's auth flow, Steam session, or network path to the backend.

## Common causes

### Steam authentication issues

The game uses Steam's WebAPI ticket system. If the client's Steam is in a weird state (offline mode, stale session, signed-out-but-cached), the ticket it generates will be rejected.

Fix: fully restart Steam on the affected user's machine, confirm they're signed in online, launch the game through Steam.

### Network interruption during the handshake

The handshake involves several round trips to `r5coopapigateway-*.windrose.support`. A brief network hiccup mid-handshake will show up as this error.

Fix: retry. If it's consistent, check for VPNs, DNS filters, or ISP-level blocks on that domain.

### Game version mismatch

If the client and server are on different patches, the BL protocol may not line up.

Fix: both sides update to the same version.

### VPN, proxy, or DNS filter interfering

VPNs can route auth traffic weirdly, proxies can strip or modify headers, and DNS filters can block backend domains.

Fix: disable these temporarily to test.

### Linux client via Proton, edge cases

Running the game through Proton generally works, but there are occasional reports of Steam ticket format mismatches. See [Linux client via Proton](../environments/linux-client-proton.md).

## What the host can do

Honestly, not much. You can confirm from your server log which account is failing and share that with the affected user, but the fix is on their side.

You should also:
- Confirm your server is on the current game version.
- Make sure you haven't accidentally hit your `MaxPlayerCount`.
- Verify the server itself is otherwise healthy (other users are connecting fine).

## What the affected user should do

1. Restart Steam fully.
2. Verify game files through Steam.
3. Disable any VPN or DNS filter temporarily.
4. Try from a different network if possible (mobile hotspot works).
5. Gather their client log and share it. See [gathering logs](../guides/gathering-logs.md). The client log will show where the handshake died, which is much more diagnostic than the host's "it didn't finish" view.

## When to report it as a bug

If multiple users are all hitting BL disconnects on the same host, and they have nothing obvious in common (not all on Linux, not all on the same ISP, all running current Steam and game version), it may be a backend or server-side issue worth reporting to the developers.

Include:
- The server log showing the disconnects
- Client logs from at least two affected users
- The game version
- Timing (when it started, whether it correlates with a patch)
