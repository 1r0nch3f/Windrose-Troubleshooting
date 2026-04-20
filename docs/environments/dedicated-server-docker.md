# Dedicated server via Docker

The community-maintained [indifferentbroccoli/windrose-server-docker](https://github.com/indifferentbroccoli/windrose-server-docker) image packages the Linux+Wine setup into a Docker container. This page covers running that (or similar images).

> This is a community image, not an official product. It inherits all the caveats of [running the server on Linux via Wine](dedicated-server-linux-wine.md). Stability depends on Wine compatibility with the current game version.

## Setup summary

The README in the upstream repo is the authoritative source. In brief:

1. Copy `.env.example` to `.env`
2. Fill in your values (invite code, server name, max players, etc.)
3. `docker compose up -d`

Or use `docker run` with the equivalent flags.

## Environment variables

Key ones from the image's README:

| Variable | Purpose |
|---|---|
| `INVITE_CODE` | The invite code players use to connect |
| `SERVER_NAME` | Display name |
| `SERVER_PASSWORD` | Leave empty for public |
| `MAX_PLAYERS` | Capacity, default 10 |
| `P2P_PROXY_ADDRESS` | Keep at default `127.0.0.1` for Docker |
| `UPDATE_ON_START` | Re-download and validate files each start |
| `GENERATE_SETTINGS` | Auto-generate config files on first start |

See the upstream README for the full list.

## Known issues specific to Docker

### gRPC assertion crash

This is the most commonly reported crash for Docker users. See [gRPC bytes_transferred assertion](../errors/grpc-assertion.md). The image bundles a specific Wine version, so upgrading Wine means either waiting for a new image tag or building your own image.

### Podman quirks

The image is designed for Docker but generally works under Podman. If you use Podman with rootless mode, double-check that:

- The mounted volume (`./server-files`) is owned by the right user (`PUID`/`PGID` env vars)
- Container networking mode doesn't interfere with the internal P2P proxy

### Container dies silently on crash

When the server inside the container crashes (like a Wine compatibility issue), the container exits. With `restart: unless-stopped`, it'll try to restart, but if the crash is deterministic on every join attempt, you'll be in a restart loop.

Check with:
```
docker logs windrose
# or for systemd-managed podman:
journalctl -u windrose.service
```

## Gathering logs

Two logs matter:

1. **The game's R5.log**, inside the container's volume at `server-files/R5/Saved/Logs/R5.log`
2. **Container stdout**, which captures Wine's output and startup info

Both are useful when reporting issues.

See [gathering logs](../guides/gathering-logs.md) for redaction tips.

## Where to report issues

- **Crash related to Wine compatibility**: file an issue at [indifferentbroccoli/windrose-server-docker/issues](https://github.com/indifferentbroccoli/windrose-server-docker/issues). The maintainer can potentially update the bundled Wine or base image.
- **Game logic issues (not Wine-related)**: report to the game developers on their official channels, but note that they may decline to fix since Docker/Wine is unsupported.

## Alternative: managed hosting

The same team behind the Docker image offers paid managed hosting at [indifferentbroccoli.com](https://indifferentbroccoli.com/windrose-server-hosting). If you don't want to debug Wine compatibility, that's the low-effort path.
