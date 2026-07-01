---
name: claude-update
description: Update the Claude Code CLI to the latest version via the dotfiles/bun install. Use when the user asks to update, upgrade, or bump Claude Code.
---

# Claude Update

Updates the Claude Code CLI to the latest version using the bun-managed install in `~/dotfiles/bun`.

## When to Use

Apply this skill when the user asks to update, upgrade, or bump Claude Code (e.g. "update claude", "claude を最新にして", "bump claude code").

## Steps

Run the following commands in order:

```bash
cd ~/dotfiles/bun
bun add @anthropic-ai/claude-code@latest
node node_modules/@anthropic-ai/claude-code/install.cjs
claude --version
```

1. `cd ~/dotfiles/bun` — move to the bun-managed install directory.
2. `bun add @anthropic-ai/claude-code@latest` — pull the latest release into `package.json` / `node_modules`.
3. `node node_modules/@anthropic-ai/claude-code/install.cjs` — run the installer that links the `claude` binary.
4. `claude --version` — confirm the new version is active.

## Notes

- Report the version printed by the final `claude --version` so the user can confirm the update landed.
- If `bun` is not found, the user needs bun installed and on `PATH` first.
