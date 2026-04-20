# Dedicated server on Windows

This is the officially-supported setup for dedicated servers.

## Requirements

Per the official guidance:

| Players | CPU | RAM | Storage |
|---|---|---|---|
| 2 | 2 cores @ 3.2 GHz | 8 GB | 35 GB SSD |
| 4 | 2 cores @ 3.2 GHz | 12 GB | 35 GB SSD |
| 10 | 2 cores @ 3.2 GHz | 16 GB | 35 GB SSD |

An SSD is strongly recommended. These numbers come from the official server documentation and the community Docker image's README.

## Getting the server files

The Windrose Dedicated Server is a free app on Steam. Install it via the Steam client, or via SteamCMD for a headless Windows host:

```
steamcmd +login anonymous +app_update <DEDICATED_SERVER_APP_ID> validate +quit
```

Check the official dedicated server guide at playwindrose.com for the current app ID.

## Configuration

Two files control server behavior, both in the server's install directory:

- **`ServerDescription.json`**, top-level server identity and connection settings
- **`WorldDescription.json`**, per-world difficulty and gameplay settings

Both can only be edited while the server is stopped.

### ServerDescription.json key fields

- `InviteCode`: the code players use to connect. Minimum 6 characters, alphanumeric, case-sensitive.
- `IsPasswordProtected`: true or false.
- `Password`: the password if protected.
- `ServerName`: display name.
- `MaxPlayerCount`: capacity.
- `P2pProxyAddress`: leave at `127.0.0.1` unless you have a specific reason to change it.

## File locations

- **Install**: wherever SteamCMD or Steam put it
- **Saves**: `<install>\R5\Saved\SaveProfiles\Default\RocksDB\<version>\Worlds\`
- **Log**: `<install>\R5\Saved\Logs\R5.log`

## Firewall

Make sure the Windows firewall allows the server executable through on both private and public networks (or at least whichever network your players are on).

## Running as a service

For a long-lived server, run it as a Windows service using a tool like NSSM (Non-Sucking Service Manager) so it auto-starts on reboot and restarts if it crashes.

## Troubleshooting

- **Server starts but nobody can connect**: see [Nobody can connect](../scenarios/nobody-can-connect.md)
- **Server crashes on join**: see [Dedicated server crashes on join](../scenarios/dedicated-server-crash.md). On native Windows this is unusual and likely indicates a genuine bug worth reporting.
- **Specific users fail**: see [Specific user can't connect](../scenarios/specific-user-fails.md)
