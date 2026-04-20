# Dedicated server crashes when someone joins

Your dedicated server process dies whenever a player tries to connect (sometimes regardless of how they connect). This is different from [Nobody can connect](nobody-can-connect.md), where the server stays up but rejects connections.

## First thing to confirm

Look at the last lines of your server log before the crash. You're looking for one of:

- An **assertion failure** followed by a callstack (the server tripped over an internal check)
- A **segmentation fault** or **access violation** message
- A process exit with no graceful shutdown

If you see a clean shutdown or a `BL disconnect` without a crash, this isn't your scenario. Go to [specific user can't connect](specific-user-fails.md).

## Environment matters a lot here

The most common reason a dedicated server crashes on join is a **compatibility issue with how you're running it**, not a bug in the game itself.

### If you're running the server on Linux via Wine or Docker

The Windrose dedicated server is Windows-only. Running it on Linux requires Wine, and Wine has known compatibility gaps with the game's networking stack (gRPC in particular).

A common symptom is an assertion like:
```
ASSERTION FAILED: result.bytes_transferred == buffer_->Length()
```
in `grpc/.../windows_endpoint.cc`. This is gRPC's Windows I/O code failing because Wine returned a different value than native Windows would.

See [dedicated server on Linux via Wine](../environments/dedicated-server-linux-wine.md) and [dedicated server via Docker](../environments/dedicated-server-docker.md) for version-specific notes and workarounds.

### If you're running on native Windows

Less common for this specific crash pattern. Likely causes:

- Corrupted server files: stop the server, delete and re-download.
- Insufficient memory: check the [server requirements](../environments/dedicated-server-windows.md#requirements).
- A specific world save that's corrupted: try starting a fresh world to isolate.
- Game patch broke something: check the official Discord for an advisory.

## Gather the full crash log

The log up to and including the crash is the single most important thing for getting help. See [gathering logs](../guides/gathering-logs.md) for where it lives on each setup.

Include at least the last 200 lines before the crash, plus the callstack. Redact account IDs and session tokens before sharing (see [redacting logs](../guides/gathering-logs.md#redacting-sensitive-data)).

## Reporting the bug

If the crash is reproducible and you've ruled out local environment issues:

- **Wine or Docker setup**: file an issue on the relevant community project (for example, the [indifferentbroccoli/windrose-server-docker issues](https://github.com/indifferentbroccoli/windrose-server-docker/issues) page).
- **Native Windows**: report to the game developers via their official Discord or Steam forum. Wine-specific bugs won't get prioritized since the server is only officially supported on Windows.
