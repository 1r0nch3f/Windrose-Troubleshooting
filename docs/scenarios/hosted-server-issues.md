# Hosted server issues (GPortal / Nitrado)

You are renting a dedicated Windrose server through GPortal or Nitrado and something has gone wrong. Pick the situation that matches yours.

---

## I cannot connect to my hosted server

You can see the server in your provider dashboard, but you or your players cannot get in.

### Quick checks (do these first)

1. **Check the server status in your dashboard.** Log into GPortal or Nitrado and confirm the status shows Online or Running. If it shows Stopped, Starting, or Restarting, wait 2-3 minutes and try again before changing anything.

2. **Confirm the IP and port are correct.** Copy the connection address directly from your provider dashboard rather than typing it manually. A single wrong character will cause a timeout.

3. **Try Direct IP in-game.** Go to Play > Connect to Server and enter the IP and port from your dashboard. This bypasses Windrose connectivity services entirely and is the fastest way to confirm whether the issue is with the backend or with your local network.

4. **Reboot your local machine and router.** Connection issues often come from stale network state on the player side, not the server side.

5. **Temporarily disable antivirus and firewall on your PC.** If that lets you connect, add a firewall exception for Windrose and Steam rather than leaving protection off.

6. **Check your ISP.** Some ISPs block dedicated server traffic by default. If you cannot connect via Direct IP either, run the [Quick-Triage script](../../scripts/) to check your local network.

### If none of the above helps

Open a support ticket with your provider. They have access to server-side logs and can confirm whether the issue is on their infrastructure.

- GPortal support: https://www.g-portal.com/en/support
- Nitrado support: https://server.nitrado.net/en-US/support
- Official Windrose FAQ: https://playwindrose.com/faq/

---

## My world is blank or missing

You logged into the server and the world is gone, empty, or reset to a new state.

> **Stop the server immediately** before doing anything else. Restarting or generating a new world while the active save folder is in a broken state can overwrite the files you need to recover.

### Check for automatic backups first

Windrose creates an automatic backup every time the server launches (up to 30 backups stored). Even if you never made a manual backup, one may already exist.

On your server, navigate to:

```
\R5\Saved\SaveProfiles\Default_Backups\
```

Backups are named by date and time. If any folders exist here, you have something to restore from.

### Restoring from a backup

1. **Stop the server** in your provider dashboard.

2. **Connect via FTP** using [Cyberduck](https://cyberduck.io/) (free). Avoid FileZilla for Windrose saves. FileZilla is known to transfer RocksDB files incorrectly, which corrupts the save on arrival. Many players have confirmed this. Use Cyberduck or another client.

3. **Find your backup folder** at `\R5\Saved\SaveProfiles\Default_Backups\` and pick the most recent one (or the last known-good date).

4. **Copy the backup contents** (the subfolder and `AccountDescription.json`) into the active save location:

   ```
   \R5\Saved\SaveProfiles\Default\RocksDB\
   ```

   Replace existing files when prompted.

5. **Start the server** and check whether the world loaded correctly. If it is still blank, stop the server again and try an older backup from the same folder.

### If the Backups folder is empty or missing

If no backups exist, contact your provider support before making any further changes. Ask specifically whether they have server-side snapshots or infrastructure-level backups from before the data was lost.

- GPortal support: https://www.g-portal.com/en/support
- Nitrado support: https://server.nitrado.net/en-US/support

If the provider has no backups either, the world data is likely unrecoverable. You can create a fresh world from your provider dashboard when you are ready.

### Preventing this in future

Windrose keeps up to 30 automatic backups in `\R5\Saved\SaveProfiles\Default_Backups\`. Periodically download a copy of that folder to your own machine using Cyberduck so you have an off-server copy that is not affected by anything on the provider side.

---

## Other resources

- [Official Windrose FAQ and troubleshooting](https://playwindrose.com/faq/)
- [Quick-Triage script](../../scripts/) — automated network check for connection problems
- [Support request template](../support-request-template.md) — what to include when asking for help in Discord
