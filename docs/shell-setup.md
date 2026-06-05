# Shell setup — VitaSound CLI tools

Canonical rules for `~/.bashrc` / `~/.zshrc`. Every CLI repo README links here.

## Format

**Two lines per tool** — do not merge multiple `bin` directories into one `PATH`:

```bash
export FMIX_HOME="<install-dir>/fmix"
export PATH="$FMIX_HOME/bin:$PATH"
```

| Tool | Env var | Verify |
|------|---------|--------|
| fmix | `FMIX_HOME` | `fmix version` |
| flint | `FLINT_HOME` | `flint version` |
| fcov | `FCOV_HOME` | `fcov version` |
| fmcp | `FMCP_HOME` | `fmcp version` |
| fhdlgen | `FHDLGEN_HOME` | `fhdlgen version` |

Libraries (**no** bashrc): frules, fsemver, ttester, fenum, f, fjson, fhdl.

## Install directory

`<install-dir>` is the parent of your clones — **`FECO_WORKSPACE`** in [feco](../README.md):

| feco location | Workspace | Example `FMIX_HOME` |
|---------------|-----------|---------------------|
| `~/feco` | `~` | `$HOME/fmix` |
| `/opt/vitasound/feco` | `/opt/vitasound` | `/opt/vitasound/fmix` |

Clones always sit **next to feco**, not forced into `$HOME`. Use an isolated workspace to avoid cluttering home.

## Bulk install

From [feco](https://github.com/VitaSound/feco):

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh          # latest release tags (user mode)
./scripts/clone-ecosystem.sh --dev      # default branches for development
```

The script prints a ready snippet for tools missing from your profile.

## Anti-pattern

Do **not** use:

```bash
alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'
```

Use `bin/<tool>` launchers — they reset the TTY correctly (WSL-safe). See [fmix README](https://github.com/VitaSound/fmix#shell-setup).

## MCP (fmcp)

Cursor `mcp.json` may set `FMIX_HOME`, `FLINT_HOME`, `FCOV_HOME` explicitly. Shell `PATH` and MCP `env` should point at the **same** workspace paths.
