# gRPC bytes_transferred assertion

## What you'll see in the log

On a **dedicated server** running under Wine:

```
R5LogNet: Error: ASSERTION FAILED: result.bytes_transferred == buffer_->Length()
    [D:\Source\Build\work\grpcRepoCheckoutDir\src\core\lib\event_engine\windows\windows_endpoint.cc:355]
```

Typically followed by a crash callstack and process exit. Callstack addresses reference `WindroseServer-Win64-Shipping.exe`, `kernel32.dll`, and `ntdll.dll`. If the kernel32 and ntdll references show paths under a Wine prefix (like `Z:\home\steam\server-files\...\dlls\kernel32\thread.c`), that confirms Wine.

## What it means

gRPC is the RPC framework Windrose uses internally. Its Windows endpoint code has a hard assertion that an async I/O completion's reported byte count equals the buffer length it asked for. On native Windows, that assertion holds. Under Wine, there are edge cases where Wine's implementation of Windows I/O Completion Ports returns a different value, so the assertion trips and the server crashes.

## Who hits this

Anyone running the dedicated server through **Wine**, including:

- Manual Wine setups on Linux (Mint, Ubuntu, Debian, etc.)
- Docker images like `indifferentbroccoli/windrose-server-docker`
- Proxmox LXC containers running Wine
- Other Wine-based wrapping (Lutris, Bottles)

Native Windows hosts do not hit this assertion.

## Official support status

The Windrose dedicated server is officially Windows-only. The developers document a Wine-based Linux setup as **experimental and not officially supported**, with no guarantees on stability. So while this crash is a real bug, it's in an unsupported configuration.

## Workarounds

### Try a newer Wine version

Wine's networking code (especially around IOCP and socket async I/O) improves across versions. If your setup uses an older Wine, upgrading may help:

- Wine stable current branch
- wine-staging (more patches, less stable)
- wine-tkg (community builds with aggressive networking patches)

Docker image users can sometimes switch tags or build their own image with a newer Wine.

### Try Proton instead of Wine

Proton is Valve's Wine fork with additional patches, some of which affect networking. Running the server through Proton is non-trivial (Proton expects a Steam-game context), but tools like [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher) make it possible.

No guarantee Proton fixes this specific assertion, but it's worth trying if Wine updates don't help.

### Run on native Windows

The only officially-supported configuration. If reliability matters and Wine isn't working for you, a small Windows VM or a cheap Windows VPS is the reliable path.

### Use managed hosting

The Docker image maintainer ([indifferent broccoli](https://indifferentbroccoli.com)) and other providers offer managed Windrose hosting. They've already dealt with the Wine compatibility pain.

## Reporting

- **If you're using the community Docker image**: file an issue at [indifferentbroccoli/windrose-server-docker/issues](https://github.com/indifferentbroccoli/windrose-server-docker/issues). Include your Wine version, Docker image tag, and the crash log.
- **If you're running Wine manually**: report to the Windrose Discord, but be aware this configuration is unsupported. Wine bugs are unlikely to get a priority fix.
- **Do not expect the game developers to fix this.** It's a Wine compatibility issue in an unsupported setup. The fix most likely has to come from Wine upstream or a patched Proton build.
