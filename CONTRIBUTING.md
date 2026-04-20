# Contributing

Thanks for considering a contribution. This repo is a community resource, and it's only as good as what people add to it.

## What's useful to contribute

**High value**:
- A new error signature you've encountered, with what you figured out about it
- A confirmed workaround for a known issue
- An update when a game patch resolves something
- A setup-specific guide for an environment not currently covered (e.g., Proxmox LXC, specific router brand quirks)

**Also welcome**:
- Clarifying confusing sections
- Fixing broken links
- Updating version-specific info as the game evolves
- Adding screenshots or diagrams where prose isn't enough

**Not useful**:
- Gameplay tips or content discussion (wrong repo)
- "Me too" issues without new information
- Changes that make content more promotional

## How to contribute

### Small fixes (typos, broken links, minor clarifications)

Open a pull request directly. No issue needed.

### New content (new error page, new guide, known-issues update)

1. Check the existing structure to see where it fits
2. Open a pull request
3. Reference any external sources (Discord threads, GitHub issues) that back up what you're writing

### Reporting something without fixing it

Open an issue describing what's missing or wrong. Someone else may pick it up, or it'll sit until someone has time.

## Style guide

### Audience

This repo is for end users trying to fix their own connection issues. Write accordingly:

- Assume general technical literacy (they can find their log files, edit a config) but not deep networking knowledge
- Explain jargon on first use, or link to the [glossary](docs/glossary.md)
- Favor concrete steps over abstract principles

### Tone

- Direct and helpful
- Honest about what's supported vs experimental
- Avoid marketing language ("amazing," "seamlessly," "effortlessly")
- Don't overpromise fixes; say "may help," "often resolves," not "will fix"

### Formatting

- Markdown, GitHub-flavored
- Headings for navigation, but don't over-nest; three levels deep is usually enough
- Code blocks for commands, file paths, and log excerpts
- Tables for comparison or lookup content
- Don't use em dashes; use commas, periods, or parentheses instead

### Structure

- One topic per file
- Start each page with what situation it's for, so readers can bail early if it's not them
- End long pages with a "if this doesn't help, try X" pointer

### Log excerpts

- Always redact (see [gathering logs](docs/guides/gathering-logs.md#redacting-sensitive-data))
- Show just enough to identify the pattern, not the entire log
- Use `...` to indicate truncation

## Review

A maintainer will review your PR for:

- Accuracy (can we reproduce or corroborate this?)
- Scope (does it fit the repo's purpose?)
- Style (does it match existing content?)

Minor issues may get fixed in merge; larger concerns come back as review comments.

## License

By contributing, you agree that your contribution is licensed under the same terms as the rest of the repo. See [LICENSE](LICENSE).
