# Diagnostic Flowchart

Work through these questions in order. Each one narrows down where the problem is.

## 1. What kind of setup are you using?

- **Self-hosted session** (you start the game and invite friends): continue to step 2
- **Dedicated server** (separate server process, running 24/7): continue to step 2, then see [dedicated server environments](environments/dedicated-server-windows.md) or [dedicated server via Docker](environments/dedicated-server-docker.md)
- **Joining someone else's server**: skip to step 4

## 2. Who is affected?

- **Nobody can connect to my server**: see [Nobody can connect](scenarios/nobody-can-connect.md). Likely a port forwarding, CGNAT, or firewall issue on the host side.
- **Some can connect, some can't**: see [Specific user can't connect](scenarios/specific-user-fails.md). Likely a problem on the affected user's side, not yours.
- **Server crashes when anyone joins**: see [Dedicated server crashes on join](scenarios/dedicated-server-crash.md). Likely a server-side bug or environment issue.

## 3. What happens during the failed connection?

- **Server log shows `Unexpected BL disconnect`**: backend authentication failure. See [BL disconnect errors](errors/bl-disconnect.md).
- **Server crashes with a callstack**: see the [error catalog](errors/README.md) and match the assertion or crash pattern.
- **Client sits at connection screen and times out**: could be port forwarding, CGNAT, or firewall. See [port forwarding guide](guides/port-forwarding.md) and [CGNAT check](guides/cgnat-check.md).
- **Connection succeeds briefly then drops**: see [Connection drops mid-session](scenarios/connection-drops.md).

## 4. If you're the one who can't connect

- **You can connect to some servers but not others**: likely something specific to the destination server (their firewall, their Wine/Docker setup, or a CGNAT on their side).
- **You can't connect to any server**: check your own firewall, Steam status, and whether your game is up to date. See [I can't join anywhere](scenarios/cant-join-anywhere.md).
- **You're running the game on Linux via Proton**: also see [Linux client via Proton](environments/linux-client-proton.md).

## 5. Always-useful first steps

Regardless of which branch you end up in, these are cheap to check and eliminate a lot of noise:

1. Restart the game and Steam on both sides.
2. Verify game files through Steam (Library, right-click Windrose, Properties, Installed Files, Verify integrity).
3. Check that Steam is fully signed in and not in offline mode.
4. Confirm both sides are on the same game version, patches often break cross-version connectivity.
5. Gather the logs before the memory of the failed attempt fades. See [gathering logs](guides/gathering-logs.md).
