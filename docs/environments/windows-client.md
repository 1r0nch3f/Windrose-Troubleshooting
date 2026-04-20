# Windows client (baseline)

This is the reference configuration: Windows 10 or 11, running the game through Steam, connecting to a host over the internet.

## What a successful connection looks like

In your client R5.log, a healthy connection shows roughly this sequence:

1. Engine boot and plugin loading
2. `R5LogSteamworks` initializes and requests a Steam ticket
3. `R5LogHttp` sends an auth request to `r5coopapigateway-*.windrose.support`, gets `IsOk true`
4. `R5LogP2pGate` creates client connections to the `coturn-*` STUN/TURN servers
5. Coop login succeeds and the server connection is verified (`Coop connection verified. BLSessionId ...`)
6. ICE/TURN establishes the P2P link
7. `Coop server connected. Start opening level...`
8. Level streaming and gameplay begin

If you get to step 7, you're connected. Everything after that is the game loading.

## Common benign warnings on Windows

These appear in nearly every successful session log and can be ignored:

- `LogStringTable: Warning: Failed to find string table entry ...`
- `LogUObjectGlobals: Warning: Gamethread hitch waiting for resource cleanup ...`
- `LogStreamlineRHI: Skip registering IDXGISwapchainProvider ...` (unless you have an NVIDIA GPU with DLSS support)
- `LogSubsystemCollection: Failed to initialize subsystem dependency (R5EosProxySystem)`, intentional, see [R5EosProxy skip](../errors/r5eosproxy-skip.md)
- `LogStreaming: Warning: LoadPackage: SkipPackage: ...` for various asset paths

## File locations

- **Install path**: wherever Steam put it, usually `C:\Program Files (x86)\Steam\steamapps\common\Windrose\` or similar on your Steam library drive
- **Log file**: `%LOCALAPPDATA%\R5\Saved\Logs\R5.log` (current) and numbered backups
- **Saves**: `%LOCALAPPDATA%\R5\Saved\SaveProfiles\`

Paste `%LOCALAPPDATA%\R5\Saved\Logs\` into File Explorer's address bar to jump there.

## Things to check when troubleshooting

1. Windows Defender Firewall: make sure Windrose (both the game and, if you self-host, the server) is allowed.
2. Third-party antivirus: some are known to interfere with game network traffic. Try temporarily disabling to test.
3. UPnP enabled on the router if self-hosting.
4. Steam is fully up to date and signed in online.
