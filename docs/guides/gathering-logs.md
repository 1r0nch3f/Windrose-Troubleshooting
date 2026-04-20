# Gathering logs

The single most useful thing when asking for help is a log file from around the time things broke. This page covers where to find it on each setup and what to strip out before sharing publicly.

## Why logs matter

Without a log, troubleshooting is guessing. With a log, you can often see exactly where things fell apart: which step in the auth handshake failed, which TURN servers were reachable, whether the game even reached the server.

The log is `R5.log`. A new one is created each session, and previous ones get numbered and rolled.

## Where R5.log lives

### Windows (game or self-hosted host)

```
%LOCALAPPDATA%\R5\Saved\Logs\R5.log
```

Paste that into File Explorer's address bar. Previous sessions are in the same folder, numbered like `R5-backup-<timestamp>.log`.

### Windows dedicated server

Under the server's install directory:

```
<server install>\R5\Saved\Logs\R5.log
```

### Linux client via Proton

Inside the Proton compatibility prefix for Windrose:

```
~/.steam/steam/steamapps/compatdata/3041230/pfx/drive_c/users/steamuser/AppData/Local/R5/Saved/Logs/R5.log
```

If `3041230` doesn't match your install, find the right `compatdata` folder by listing `~/.steam/steam/steamapps/compatdata/` and checking modification times after a recent launch.

### Steam Deck

Same path as Linux Proton, under the deck user's home:

```
/home/deck/.steam/steam/steamapps/compatdata/3041230/pfx/drive_c/users/steamuser/AppData/Local/R5/Saved/Logs/R5.log
```

### Linux dedicated server via Wine

Depends on your Wine prefix. If following the official guide with prefix at `/home/<user>/steam/windrose/pfx`:

```
<prefix>/drive_c/users/<user>/AppData/Local/R5/Saved/Logs/R5.log
```

### Docker dedicated server

In the mounted volume:

```
./server-files/R5/Saved/Logs/R5.log
```

Container stdout is also useful. Grab it with:
```
docker logs windrose > container.log
# or for podman with systemd:
journalctl -u windrose.service > container.log
```

## Which log do I want?

- **Latest session**: the one that was most recently modified.
- **Specific failed attempt**: check the timestamps in the filename or within the log. The first line shows the session start time.
- **Server crash**: the log from the session that crashed. If the server auto-restarts, the crash log is the previous one, not the currently active one.

## Redacting sensitive data

R5.log contains a few things you probably don't want to share publicly:

### Account IDs and session IDs

Look for:
- `AccountId <32-char hex>`
- `BLSessionId <32-char hex>`
- `BLPlayerSessionId '<32-char hex>'`
- `IslandId '<32-char hex>'`
- `PersistentServerId '<32-char hex>'`

These identify specific players and sessions. Replace them with `<redacted>` or `XXXXXX` if sharing publicly. They're less dangerous than credentials but still identifying.

### Steam ticket blobs

The log may contain a very long hex string after `Created Steam Ticket:`. That's your Steam authentication ticket for that session. Tickets are short-lived but still worth redacting. Replace the hex blob with `<redacted>`.

### Command-line arguments

The log echoes the full command line used to launch the game, which includes some base64-encoded auth tokens and paths containing your username. Look for the line starting `Args '...'` near the top and redact the base64 strings and home-directory paths.

### Usernames in file paths

Paths like `C:\Users\<yourname>\...` and `/home/<yourname>/...` leak your system username. Search and replace before sharing.

## Quick redaction script

A rough sed one-liner for Linux/Mac or Git Bash on Windows:

```bash
sed -E \
    -e 's/[0-9a-fA-F]{32}/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/g' \
    -e 's#(C:\\Users\\)[^\\]+#\1USER#g' \
    -e 's#(/home/)[^/]+#\1user#g' \
    R5.log > R5-redacted.log
```

That replaces all 32-char hex IDs and home-directory usernames. You'll still want to eyeball the result for anything else.

## How much to share

- **Small issue (a specific error you want matched)**: the last ~200 lines is usually enough. `tail -200 R5.log > R5-tail.log`.
- **Crash**: share from about 100 lines before the crash through the end of the file.
- **Connection problem**: share from the session start through the point of failure. The first ~100 lines (init, Steam auth, backend auth) are often the most relevant.
- **Long-running server**: grep for the specific error or player session, and share ~50 lines of context around each hit.

## Attaching in Discord

Discord has a 25 MB file size limit for most servers. R5.log files can exceed this for long sessions. Options:

- Truncate to the relevant range (see above)
- Zip the file (text logs compress well, usually 10x+)
- Paste a snippet inline using code blocks if it's short enough

Don't paste tens of thousands of lines into chat; it drowns the channel and makes it harder for supporters to help you.
