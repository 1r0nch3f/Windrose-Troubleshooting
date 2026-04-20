# Known issues

Reproducible bugs and their workarounds. Updated as the game gets patched.

> Each issue is dated. If you're reading this months after the last update, check whether the issue still reproduces before assuming it's current.

## Active issues

### gRPC assertion crash on Linux dedicated server

**First seen**: Early access launch, April 2026
**Status**: Active, unresolved
**Affects**: Dedicated servers running under Wine on Linux (including Docker images)
**Symptoms**: Server crashes with `ASSERTION FAILED: result.bytes_transferred == buffer_->Length()` in `windows_endpoint.cc` when a player attempts to join.

**Workarounds**:
- Newer Wine version may help (wine-staging, wine-tkg)
- Try running under Proton via umu-launcher instead of Wine
- Run on native Windows instead

**Details**: [gRPC assertion error](errors/grpc-assertion.md)

### BL disconnect on specific users

**First seen**: Early access, various reports
**Status**: Active, root cause varies per case
**Affects**: Individual users, often but not always on specific setups (Linux/Proton has been commonly reported)
**Symptoms**: Server log shows `Unexpected BL disconnect` for a specific player while others connect fine.

**Workarounds**:
- Affected user restarts Steam fully
- Affected user tries a different Proton version (if on Linux)
- Affected user disables VPN/DNS filter
- Affected user tries from a different network to rule out ISP filtering

**Details**: [BL disconnect errors](errors/bl-disconnect.md)

## Placeholder entries (add details as we confirm them)

### Steam Deck unverified status

The game works on Steam Deck via Proton but is officially "Unverified." Gameplay issues include controller mapping gaps in the character creation menu. Not a networking issue per se, but commonly raised.

## Resolved issues

*(Move entries here when a game patch fixes them, with a note about which version.)*

## How to add to this list

When you encounter a reproducible issue not listed here:

1. Confirm it reproduces on a clean setup, not just yours
2. Get at least one other person to confirm
3. Open a pull request adding an entry here with:
   - First seen date
   - Current status
   - What setups are affected
   - Concrete symptoms (log lines, error messages)
   - Any workarounds found
   - Link to a deeper writeup in `errors/` or `scenarios/` if applicable

When a patch fixes something here, move the entry to "Resolved issues" with the patch version rather than deleting it, so people searching for the symptom still find the history.
