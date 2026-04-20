# Linux client via Proton

Windrose does not ship a native Linux build, but it runs on Linux through Proton (including the Steam Deck). It's marked as "Unverified" on the Steam Deck compatibility scale, not "Verified" or "Playable," which means Valve hasn't officially vetted it but users report it generally works.

## Proton versions

There's no single "correct" Proton version. What works best varies across game patches. If you're having issues, try these in order:

1. **Proton Experimental** (Steam's current cutting-edge build, gets frequent updates)
2. **Proton stable** (whatever the latest numbered version is)
3. **Proton GE** (community build with additional patches, installed via ProtonUp-Qt or similar)
4. **An older Proton version** if a recent update broke things

You can switch per-game: Steam library, right-click Windrose, Properties, Compatibility, Force the use of a specific Steam Play compatibility tool.

## Known quirks

### Steam ticket occasionally rejected

Some users report intermittent [BL disconnect](../errors/bl-disconnect.md) errors on the server side when connecting from a Linux/Proton client. The working theory is that specific Proton versions produce Steam WebAPI tickets that get rejected during the backend handshake.

Fix: try a different Proton version. Proton Experimental and Proton GE are good first alternatives.

### First launch takes forever

Proton compiles shaders on first launch. The game can sit at a black screen for several minutes the first time. This is normal.

If it sits at a black screen indefinitely after the first launch, that's different and may indicate a real problem.

### Controller input issues

Windrose's controller support is incomplete. On Steam Deck, you'll likely need to configure a custom control layout. This is a gameplay issue, not a networking one.

## File locations

Saves and logs live inside the Proton prefix:

```
~/.steam/steam/steamapps/compatdata/3041230/pfx/drive_c/users/steamuser/AppData/Local/R5/Saved/
```

The log file is at:
```
~/.steam/steam/steamapps/compatdata/3041230/pfx/drive_c/users/steamuser/AppData/Local/R5/Saved/Logs/R5.log
```

(The app ID `3041230` is Windrose's Steam app ID; if the path doesn't match, find the right `compatdata` folder by looking at the modification times.)

On the Steam Deck, the path is the same but under the deck user's home directory.

## Alternative: Bazzite, Nobara, and other gaming-focused distros

Users on gaming-focused distros report good experiences. These distros ship with sane defaults for Proton, gamemode, and the GPU userspace, which removes some classes of configuration issue.

## If you're hosting from a Linux client

You can host a self-hosted session from Linux via Proton. This is distinct from running the **dedicated server** on Linux, which is a separate, more experimental setup. If you want dedicated, see [dedicated server on Linux via Wine](dedicated-server-linux-wine.md) instead.

## Gathering your log to share

See [gathering logs](../guides/gathering-logs.md), which covers the Proton path.
