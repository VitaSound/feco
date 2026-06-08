# feco — agent instructions

[Russian version](AGENTS.ru.md)

Catalog of the VitaSound Forth ecosystem: `README.md` for humans, `data/tags.json` for versions from GitHub, `data/coverage.json` for definition coverage from **Cov badges** in local clone READMEs.

## MCP (preferred for agents)

Use the **`vitasound-forth`** MCP server (Cursor: Settings → MCP). Tool names below — **not** shell aliases (`fmix test`, `fcov run`, …).

**`project_root`** for feco catalog work: absolute path to this repo (e.g. `/home/sea/feco`). For work inside a library clone: absolute path under **`FECO_WORKSPACE`** (default: parent of feco, e.g. `/home/sea/fmix`).

| MCP tool | Use in feco | Notes |
|----------|-------------|-------|
| `mcp_ping` | Session health before/after batch work | No arguments |
| `fetch_tags` | Refresh **`data/tags.json`** | Runs `./scripts/fetch-tags.sh` under `project_root` |
| `fmix_check` | Quality gate in one ecosystem repo | `stage`, optional `fail_under`, `no_flint`, `no_fcov` |
| `fcov_run` | `fcov run fmix test` in one repo (dev only) | Not for catalog refresh |
| `fcov_report` | Coverage JSON for one repo | After `fcov_run` in that repo |
| `gforth_eval` | Quick Gforth checks | `project_root`, `source` |
| `shell_run` | Scripts **without** a dedicated MCP tool | See fallback table below |

**Do not** call `./scripts/fetch-tags.sh` or `fmix check` via shell when the matching MCP tool exists and the server is connected.

Call MCP tools **one at a time** (no parallel `tools/call`). Use **`mcp_ping`** between heavy calls. If the session drops (`Connection closed`), restart MCP in Settings and continue; inspect `$FMCP_HOME/.fmcp/serve.log`.

### Refresh catalog table (MCP workflow)

Typical sequence when the user asks to update versions / coverage in the README table:

1. **`mcp_ping`**
2. **`fetch_tags`** — `project_root` = feco root → writes `data/tags.json`
3. **`mcp_ping`**
4. **`shell_run`** — `project_root` = feco root, command:
   `./scripts/fetch-coverage.sh && ./scripts/update-readme-versions.sh`
5. **`mcp_ping`**

`fetch-coverage.sh` reads **Cov badges** from `$FECO_WORKSPACE/<repo>/README.md` (`source: readme-badge`). Each ecosystem repo maintains its own badge after `fmix check` / release — feco does **not** batch-run `fcov` across clones.

Optional: **`gforth_eval`** on feco or a clone; **`fcov_run`** only when developing inside one repo.

### MCP vs shell (fallback)

| Task | Prefer MCP | Shell fallback (no MCP / clone setup) |
|------|------------|--------------------------------------|
| Ecosystem tags → `data/tags.json` | `fetch_tags` | `./scripts/fetch-tags.sh` |
| Aggregate coverage + README columns | `shell_run` (see workflow above) | `fetch-coverage.sh` + `update-readme-versions.sh` |
| Quality gate in one repo | `fmix_check` | `fmix check` in that clone |
| Clone / sync all repos | — | `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh` |

Scripts remain the **source of truth** for CI and humans; MCP wraps them where noted. Details: [fmcp/AGENTS.md](https://github.com/VitaSound/fmcp/blob/main/AGENTS.md).

## Clone the ecosystem

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh              # user mode → latest semver tags
./scripts/clone-ecosystem.sh --dev        # dev mode → main branches (for commits)
./scripts/clone-ecosystem.sh --check-only # preflight + bashrc snippet preview
```

Repos clone into **`FECO_WORKSPACE`** (default: parent of feco). If feco is `~/feco`, clones are `~/fmix`, `~/frules`, …

- **SSH by default** (`git@github.com:VitaSound/<repo>.git`); `--https` for HTTPS.
- **user mode** (default): checkout latest semver tag.
- **dev mode** (`--dev`): checkout and pull default branch (`main`).

Shell setup after clone: [docs/shell-setup.md](docs/shell-setup.md).

## Update the ecosystem

```bash
./scripts/update-ecosystem.sh              # tags.json + clones + README + packages.get
./scripts/update-ecosystem.sh --dev        # pull branches instead of tags
./scripts/update-ecosystem.sh --no-packages
```

Agents with MCP: use the **Refresh catalog table** workflow instead of reimplementing its steps.

## Refresh the catalog (tags only)

**Agent:** `fetch_tags` with `project_root` = feco root.

**Human / CI:**

```bash
./scripts/fetch-tags.sh
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

## Refresh coverage (README badges)

**Default** — no `fcov run` batch:

```bash
./scripts/fetch-coverage.sh
./scripts/fetch-coverage.sh --table
jq '.repos.fjson.coverage_pct' data/coverage.json
```

Reads `badge/Cov-NN%` from `$FECO_WORKSPACE/<repo>/README.md`. Repos without a badge → `coverage_pct: null` → table shows `—`.

**Debug only:** `./scripts/fetch-coverage.sh --local` reads `.fcov/coverage.json` from clones.

## Update README

`./scripts/update-readme-versions.sh` updates version / coverage columns. Manual rules:

1. **Version** / **Версия** ← `repos.<name>.latest` (if `null`, use `—`).
2. **Last updated** / **Последнее обновление** — from local clone at `FECO_WORKSPACE/<name>` when present.
3. **% coverage** / **% покрытия** ← `data/coverage.json` → `repos.<name>.coverage_pct` (from README badge).
4. Footnote: `data/tags.json`, `data/coverage.json`, `fetched_at`, script names.
5. Do not change **Purpose** / **Назначение** or links unless asked.
6. Keep `README.md` and `README.ru.md` in sync.

## Add a new ecosystem repo

1. Add the name to `catalog/repos.list`.
2. Add a row to the tables in `README.md` and `README.ru.md`.
3. **`fetch_tags`** (MCP) or `./scripts/fetch-tags.sh`, then `fetch-coverage.sh` + `update-readme-versions.sh`.

## Default branches

| Repo | GitHub default |
|------|----------------|
| fmix, fhdl | `main` |
| others | `main` |

Scripts detect via `git remote show` / `ls-remote --symref`.

## Dependencies

`git`, `jq`, `gforth` ≥ 0.7.9. Preflight warns on pending `apt` upgrades and snap gforth. MCP additionally requires `fmcp` in Cursor `mcp.json` (`FMCP_HOME`, `FMIX_HOME`, `FLINT_HOME`, `FCOV_HOME`, `PATH`).
