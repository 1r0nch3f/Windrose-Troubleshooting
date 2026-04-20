# Support request template

Copy this template and fill it in when asking for help in the tech-support channel. Giving supporters this info up front avoids a dozen back-and-forth clarification messages.

## Template (copy from here)

```
**What's broken**
One sentence describing the problem.

**Setup**
- OS: (Windows 11 / Windows 10 / Linux distro / Steam Deck / etc.)
- Running through: (Steam natively / Proton <version> / Wine <version> / Docker)
- Self-hosted session / Dedicated server (native Windows) / Dedicated server (Linux+Wine) / Dedicated server (Docker) / Just a client
- Game version: (from the main menu)

**Who's affected**
- Everyone can't connect / Specific users can't / Only me / My server crashes

**What I've already tried**
- List the things you've done.
- Especially mention if you've tried: restarting Steam, verifying game files, restarting the router, checking firewall, different Proton/Wine version.

**What the log shows**
- Attach R5.log (redacted, see the guide).
- Or paste the key error lines inline in a code block.
- Mention the timestamp of the failed attempt so supporters know where to look.

**Anything else**
- ISP (especially if you suspect CGNAT)
- Any recent changes to your setup
- Whether this used to work and just broke
```

## Tips for a good request

### Be specific about what "doesn't work" means

"Can't connect" covers a lot of ground. More useful:
- "Client shows connection timeout after ~30 seconds"
- "Server log shows BL disconnect, client sits at loading screen then kicks back to menu"
- "Server crashes with a callstack within 2 seconds of the join attempt"

### Don't paste 10,000 lines of log in chat

Attach the log as a file, or paste the relevant 20-50 lines in a code block. Channel members can't scroll through a novel.

### Redact before sharing

See [gathering logs](guides/gathering-logs.md#redacting-sensitive-data). Strip account IDs, Steam tickets, and home directory paths.

### Tell us what you already tried

Nothing is more frustrating for supporters than suggesting something and finding out five replies later that you already tried it.

### Respond to questions

If someone asks for more info, providing it promptly is the fastest way to resolution. Supporters are volunteers; if you disappear for a day after asking a question, the thread usually goes cold.

### Mark it solved when it's solved

If something fixed your issue, say so in the thread so the next person searching for the same problem finds the answer. Even better: propose that fix as a contribution to this repo.
