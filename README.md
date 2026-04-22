# Windrose Networking Troubleshooting

Community-maintained troubleshooting guide for Windrose connection and networking issues. Start here before posting in the Discord tech-support channel.

> This is a community resource, not official support. The game developers run the official support channels. If you confirm a bug here, report it to the developers via their Discord or Steam forum.

## Start here

Pick the statement that best matches your situation:

| Your situation | Go to |
|---|---|
| I can host, but nobody can join my server | [Nobody can connect](docs/scenarios/nobody-can-connect.md) |
| Some friends can join, one or two can't | [Specific user can't connect](docs/scenarios/specific-user-fails.md) |
| I can't join any server, but others can | [I can't join anywhere](docs/scenarios/cant-join-anywhere.md) |
| My dedicated server crashes when someone tries to join | [Dedicated server crashes on join](docs/scenarios/dedicated-server-crash.md) |
| Connection works, then drops after a while | [Connection drops mid-session](docs/scenarios/connection-drops.md) |
| I get an infinite loading screen after the Unreal logo | [Steam Cloud save corruption (RocksDB)](docs/errors/save-corruption-rocksdb.md) |
| I can't connect to multiplayer and I may not have finished the tutorial | [Tutorial not completed](docs/scenarios/tutorial-not-completed.md) |
| I rent a server through GPortal or Nitrado and can't connect or lost my world | [Hosted server issues (GPortal / Nitrado)](docs/scenarios/hosted-server-issues.md) |
| I see a specific error message | [Error signature catalog](docs/errors/README.md) |
| I want an automated quick check of my connection | [Run Quick-Triage](scripts/) |
| Not sure | [Full diagnostic flowchart](docs/diagnostic-flowchart.md) |

## Before asking for help

If you still need help after trying the relevant guide, post in the tech-support channel with the info from the [support request template](docs/support-request-template.md). Giving supporters this info up front saves everyone time.

The single most useful thing you can attach is your log file. The [log gathering guide](docs/guides/gathering-logs.md) shows where to find it on each platform and what to redact before sharing.

## Repository layout

- [`docs/diagnostic-flowchart.md`](docs/diagnostic-flowchart.md), decision tree for narrowing down the issue
- [`docs/scenarios/`](docs/scenarios/), walk-throughs grouped by symptom
  - [`tutorial-not-completed.md`](docs/scenarios/tutorial-not-completed.md), tutorial gate: why players are silently dropped before multiplayer even starts
  - [`hosted-server-issues.md`](docs/scenarios/hosted-server-issues.md), GPortal and Nitrado: can't connect, blank world, and save restore
- [`docs/errors/`](docs/errors/), catalog of known error messages and what they mean
  - [`save-corruption-rocksdb.md`](docs/errors/save-corruption-rocksdb.md), Steam Cloud duplicate MANIFEST causing infinite loading screen
- [`docs/environments/`](docs/environments/), setup-specific notes (Windows, Linux client via Proton, Linux server via Wine, Docker, etc.)
- [`docs/guides/`](docs/guides/), cross-cutting how-tos (log gathering, port forwarding, CGNAT checks, IPv4 priority)
  - [`ipv4-priority.md`](docs/guides/ipv4-priority.md), demoting IPv6 below IPv4 for the IPv4-only Windrose backend
- [`docs/known-issues.md`](docs/known-issues.md), living list of reproducible bugs and workarounds
- [`docs/support-request-template.md`](docs/support-request-template.md), what to include when asking for help
- [`docs/glossary.md`](docs/glossary.md), networking and game-specific terms
- [`scripts/`](scripts/), standalone diagnostic scripts you can run directly from PowerShell

## Contributing

Found a fix that isn't documented here? Hit a new error? Open a pull request or an issue. See [CONTRIBUTING.md](CONTRIBUTING.md) for the style guide and what makes a good contribution.

## Scope

This repo covers networking and connection issues only. For gameplay questions, performance tuning, or content bugs, use the official support channels.
