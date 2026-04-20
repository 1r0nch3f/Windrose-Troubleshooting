# Error catalog

Common error signatures from Windrose logs, what they mean, and how to respond.

## How to use this catalog

Search your log for the error text, then find it here. Each entry explains:

- What the error actually means
- Which side of the connection sees it (client, server, or both)
- Likely causes
- What to try

## Errors by signature

| Error text | Meaning | Link |
|---|---|---|
| `Unexpected BL disconnect` | Backend authentication handshake failed for a player | [BL disconnect errors](bl-disconnect.md) |
| `ASSERTION FAILED: result.bytes_transferred == buffer_->Length()` | gRPC networking assertion, usually Wine compatibility issue | [gRPC bytes_transferred assertion](grpc-assertion.md) |
| `Failed to initialize subsystem dependency (R5EosProxySystem)` | EOS subsystem skipped (often intentional, not a real error) | [R5EosProxy skip](r5eosproxy-skip.md) |
| `Cannot connect to turn server` | P2P TURN relay fallback failed | [TURN connection failures](turn-failures.md) |
| `Steam ticket` auth-related errors | Steam authentication ticket rejected | [Steam ticket failures](steam-ticket.md) |

## Errors by component

- **R5LogNetBL**: Backend Link, handles player authentication and session state
- **R5LogDataKeeper**: Tracks player state on the server
- **R5LogP2pGate**: Peer-to-peer connection setup (ICE/STUN/TURN)
- **R5LogIceProtocol**: ICE protocol specifics for P2P
- **R5LogSteamworks**: Steam integration
- **R5LogAuthProxy**: Authentication proxy
- **R5LogCoopProxy**: Co-op session coordination
- **R5LogEosProxy**: Epic Online Services (usually skipped in current builds)

Warnings from these components do not always mean something is broken. The game logs a lot of verbose information during normal operation.

## Benign log noise (safe to ignore)

These show up frequently and usually do not indicate a real problem:

- `Failed to find string table entry for ...`: missing localization strings
- `Gamethread hitch waiting for resource cleanup`: minor loading hitches
- `LogStreaming: Warning: LoadPackage: SkipPackage: ...`: optional asset missing, game continues fine
- `R5LogTerrainGeneratorSubsystem: Warning: Material contains layer ...`: content warnings, not gameplay-affecting
- `LogStreamlineRHI: Skip registering ...`: DLSS feature detection, expected on non-NVIDIA hardware

## Do not see your error here?

Contribute it. Open a pull request adding a new entry to this catalog with:

1. The exact error text (redacted if it contains IDs)
2. Which component logged it (the `R5Log*` prefix)
3. What you were doing when it happened
4. What resolved it, if you found a fix
