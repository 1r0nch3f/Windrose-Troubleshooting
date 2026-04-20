# Dedicated server on Linux via Wine

> **Unofficial and experimental.** The Windrose dedicated server binary is Windows-only. Running it on Linux requires Wine and is explicitly not officially supported by the developers. Stability, performance, and compatibility are not guaranteed.

If you want a reliable dedicated server and don't want to deal with Wine quirks, run it on native Windows instead. See [dedicated server on Windows](dedicated-server-windows.md).

## The official Linux guide

The game developers publish a community-oriented guide at `playwindrose.com/dedicated-server-guide/` that walks through setting up the server on Debian-based distros (Ubuntu, Mint) using Wine. The guide is confirmed working on Mint 22.3. Other distros should work if the dependencies are available.

Key dependencies the guide calls out:

- `software-properties-common`, `lib32gcc-s1`, `steamcmd`
- `wine-installer` (for a recent Wine)
- `multiverse` and `i386` architecture enabled
- A working graphical session isn't required; the server is headless

## Known issues

### gRPC assertion crash on player join

The most commonly reported issue. See [gRPC bytes_transferred assertion](../errors/grpc-assertion.md). Shows up as an assertion failure in `windows_endpoint.cc` and crashes the server when a player tries to join.

This is a Wine compatibility problem with gRPC's Windows I/O code. Newer Wine versions, wine-staging, wine-tkg, or Proton may work better.

### Steam auth occasionally flaky

The server needs to authenticate to Steam on startup. Wine's Steam integration is generally fine but can fail transiently. A restart usually resolves it.

### Updates via SteamCMD

The server app is updated through SteamCMD. Wine doesn't interfere with this since SteamCMD is a native Linux binary; only the server executable itself runs under Wine.

## Wine version recommendations

There's no single "right" version, but:

- Avoid very old Wine (anything older than 8.x)
- Wine 9.x and 10.x have significantly improved networking
- Wine staging includes patches not yet in stable
- Wine-tkg is community-maintained with aggressive patches, sometimes fixes things stable doesn't

Upgrade Wine first if you're hitting crashes or weird behavior before assuming the game is broken.

## Alternative: Proton instead of Wine

Proton is Valve's Wine fork with additional patches. Some of those patches help networking. Running the server under Proton instead of Wine is possible but non-trivial:

- Install Proton outside of Steam (download from GitHub releases for Proton GE, or extract from a Steam install for Valve's Proton)
- Set up the environment variables Proton expects (`STEAM_COMPAT_DATA_PATH`, `STEAM_COMPAT_CLIENT_INSTALL_PATH`)
- Launch the server via [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher) which handles Proton outside Steam

No guarantee this fixes your specific issue, but it's an option.

## File locations

Everything lives under your Wine prefix. The guide suggests `/home/<user>/steam/windrose/pfx` as the prefix, with the actual server files at `drive_c/` inside that.

Server logs end up at something like:
```
<prefix>/drive_c/users/<user>/AppData/Local/R5/Saved/Logs/R5.log
```

Systemd journal entries from the wrapper script will also capture stdout from the Wine process, which mirrors parts of the log.

## If you just want it to work

Three pragmatic options:

1. **Run on native Windows** via a small VM or Windows VPS
2. **Use managed hosting** from providers like [indifferent broccoli](https://indifferentbroccoli.com)
3. **Try the Docker image** ([indifferentbroccoli/windrose-server-docker](https://github.com/indifferentbroccoli/windrose-server-docker)) which packages the Wine setup into a container

Each has tradeoffs in cost, convenience, and how much you have to maintain yourself.
