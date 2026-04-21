# Tutorial not completed

Every Windrose player must finish the single-player tutorial before their client can connect to multiplayer. This applies to both the host and anyone trying to join. The game gives no error message when this is the problem.

Hosting providers estimate this accounts for roughly half of all Windrose multiplayer support tickets.

## Symptoms

- Silently dropped back to the main menu after a loading screen, with no error message.
- Infinite loading screen when attempting to join.

These symptoms are identical to some network issues, which is why this check comes first.

## How to verify

Tutorial completion is tied to the Steam account, not the machine. A player who has finished the tutorial on one account has not finished it on another.

Check whether this specific Steam account has completed the tutorial:

1. From the main menu, see whether the single-player tutorial is still available to start.
2. If the game was recently installed, if the player recently switched Steam accounts, or if the account is a family-share copy, the tutorial has almost certainly not been finished on that account.

There is no badge or completion flag to look for. If the tutorial is available to play, it has not been finished.

## Fix

Finish the single-player tutorial on the affected account. Both the host and every player trying to join need their own completion on their own account.

Once the tutorial is done, retry the multiplayer connection.

## How to tell this apart from a real network issue

A few clues that point toward the tutorial gate rather than a network problem:

- No error message is shown at any point.
- The failure is completely silent: loading screen, then back to menu.
- The problem goes away immediately after finishing the tutorial.
- Every account trying to connect is affected until each one individually finishes it.

If you have confirmed the tutorial is complete on the affected account and the problem continues, see [I can't join anywhere](cant-join-anywhere.md) for network-side causes.
