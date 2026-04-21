# Steam Cloud save corruption (RocksDB duplicate MANIFEST)

## Symptoms

Infinite loading screen after the Unreal Engine splash, with no error message. The game never reaches the main menu.

## What causes this

Windrose stores save data in a RocksDB database. The `CURRENT` file in that folder is a single line of text pointing at the active manifest file, for example `MANIFEST-000042`.

When Steam Cloud syncs saves between machines, it can leave two `MANIFEST-XXXXXX` files in the folder. The `CURRENT` file may then point at the wrong one, which causes RocksDB to fail to open the database, and the game hangs.

## Locating the folder

```
%LOCALAPPDATA%\R5\Saved\SaveProfiles\<SteamID>\RocksDB\<version>\Players\<playerId>\
```

Replace `<SteamID>`, `<version>`, and `<playerId>` with the actual folder names present on your machine. There is usually only one subfolder at each level.

## Fix

1. Open the folder above in Explorer.
2. Look for two or more files named `MANIFEST-XXXXXX` (six-digit numbers).
3. Check the timestamps. The newer file is usually the correct one.
4. Open `CURRENT` in a text editor (Notepad works). It contains a single filename, for example `MANIFEST-000042`.
5. If that filename does not match the newer MANIFEST file, edit `CURRENT` to contain the correct filename.
6. Save the file. Keep the trailing newline. Removing it breaks RocksDB's file parsing.
7. Launch the game.

Do not delete either MANIFEST file until you have confirmed the game loads correctly.

## Workaround

If you play on more than one machine, disable Steam Cloud sync for Windrose in Steam's game properties. Manual save management avoids this conflict entirely.

## Backups

Recent patches added 30 rolling auto-backups, written on every launch. Check this folder if you need to recover an earlier save state:

```
%LOCALAPPDATA%\R5\Saved\SaveProfiles\<SteamID>\RocksDB\<version>\Backups\
```
