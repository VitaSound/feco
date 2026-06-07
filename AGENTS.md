# feco — agent instructions

[Russian version](AGENTS.ru.md)

Catalog of the VitaSound Forth ecosystem: `README.md` for humans, `data/tags.json` for versions from GitHub, `data/coverage.json` for definition coverage from local `fcov` runs.

## MCP (preferred for agents)

Use the **`vitasound-forth`** MCP server (Cursor: Settings → MCP). Tool names below — **not** shell aliases (`fmix test`, `fcov run`, …).

**`project_root`** for feco catalog work: absolute path to this repo (e.g. `/home/sea/feco`). For coverage per library: absolute path to that clone under **`FECO_WORKSPACE`** (default: parent of feco, e.g. `/home/sea/fmix`).

| MCP tool | Use in feco | Notes |
|----------|-------------|-------|
| `mcp_ping` | Session health before/after batch work | No arguments |
| `fetch_tags` | Refresh **`data/tags.json`** | Runs `./scripts/fetch-tags.sh` under `project_root` |
| `fcov_run` | `fcov run fmix test` in one ecosystem repo | One repo per call; optional `timeout_seconds` (default 300) |
| `fcov_report` | Coverage JSON for one repo | After `fcov_run` |
| `gforth_eval` | Quick Gforth checks | `project_root`, `source` |
| `shell_run` | Scripts **without** a dedicated MCP tool | See fallback table below |

**Do not** call `./scripts/fetch-tags.sh`, `fcov run`, or `fmix test` via shell when the matching MCP tool exists and the server is connected.

Call MCP tools **one at a time** (no parallel `tools/call`). Use **`mcp_ping`** between repos when running many `fcov_run` calls. If the session drops (`Connection closed`), restart MCP in Settings and continue; inspect `$FMCP_HOME/.fmcp/serve.log`.

### Refresh catalog table (MCP workflow)

Typical sequence when the user asks to update versions / coverage in the README table:

1. **`mcp_ping`**
2. **`fetch_tags`** — `project_root` = feco root → writes `data/tags.json`
3. **`mcp_ping`**
4. **`fcov_run`** — for each repo in `catalog/repos.list` that has `package.4th` under `FECO_WORKSPACE/<name>`; `project_root` = that clone (skip `flint_lint` in the same session)
5. **`mcp_ping`** (between repos if the batch is long)
6. **`shell_run`** — `project_root` = feco root, command:
   `./scripts/fetch-coverage.sh && ./scripts/update-readme-versions.sh`
7. **`mcp_ping`**

`fetch-coverage.sh` aggregates `.fcov/coverage.json` from local clones; `update-readme-versions.sh` updates `README.md` / `README.ru.md` from `data/tags.json` + `data/coverage.json`.

Optional: **`gforth_eval`** on feco or a clone to sanity-check a word; **`fcov_report`** on one repo for raw JSON.

### MCP vs shell (fallback)

| Task | Prefer MCP | Shell fallback (no MCP / clone setup) |
|------|------------|--------------------------------------|
| Ecosystem tags → `data/tags.json` | `fetch_tags` | `./scripts/fetch-tags.sh` |
| Coverage in one repo | `fcov_run` | `cd $repo && fcov run fmix test` |
| Aggregate coverage + README columns | `shell_run` (see workflow above) | same scripts |
| Clone / sync all repos | — | `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh` |

Scripts remain the **source of truth** for CI and humans; MCP wraps them where noted. Details: [fmcp/AGENTS.md](https://github.com/VitaSound/fmcp/blob/main/AGENTS.md).

## Clone the ecosystem

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh              # user mode → latest semver tags
./scripts/clone-ecosystem.sh --dev        # dev mode → main/master (for commits)
./scripts/clone-ecosystem.sh --check-only # preflight + bashrc snippet preview
```

Repos clone into **`FECO_WORKSPACE`** (default: parent of feco). If feco is `~/feco`, clones are `~/fmix`, `~/frules`, … If feco is `/opt/vitasound/feco`, clones are `/opt/vitasound/fmix`, … — isolated workspace, home stays clean.

- **SSH by default** (`git@github.com:VitaSound/<repo>.git`); `--https` for HTTPS.
- **user mode** (default): checkout latest semver tag.
- **dev mode** (`--dev`): checkout and pull default branch (`main`; `master` for fmix/fhdl until migrated).

Shell setup after clone: [docs/shell-setup.md](docs/shell-setup.md).

## Update the ecosystem

```bash
./scripts/update-ecosystem.sh              # tags.json + clones + README + packages.get
./scripts/update-ecosystem.sh --dev        # pull branches instead of tags
./scripts/update-ecosystem.sh --no-packages
```

Agents with MCP: use the **Refresh catalog table** workflow instead of reimplementing its steps; use `update-ecosystem.sh` only when the user wants full clone sync or no MCP is available.

## Refresh the catalog (tags only)

**Agent:** `fetch_tags` with `project_root` = feco root.

**Human / CI:**

```bash
./scripts/fetch-tags.sh
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

For each repo in `catalog/repos.list`, the script runs `git ls-remote --tags` and picks the **latest semver tag** (`sort -V | tail -1`, strips a leading `v`).

## Refresh coverage (local clones)

After **`fcov_run`** on each clone (MCP), aggregate with:

```bash
./scripts/fetch-coverage.sh
./scripts/fetch-coverage.sh --table
jq '.repos.fjson.coverage_pct' data/coverage.json
```

Reads `FECO_WORKSPACE/<repo>/.fcov/coverage.json`. Repos without that file are omitted from `data/coverage.json`; the README shows `—`.

## Update README

`./scripts/update-readme-versions.sh` (also run from `update-ecosystem.sh` and via MCP `shell_run`) updates version / coverage columns. Manual rules:

1. **Version** / **Версия** ← `repos.<name>.latest` (if `null`, use `—`).
2. **Last updated** / **Последнее обновление** — from local clone at `FECO_WORKSPACE/<name>` when present.
3. **% coverage** / **% покрытия** ← `data/coverage.json` → `repos.<name>.coverage_pct` (if missing, use `—`). Definition coverage via `fcov run fmix test` only.
4. Footnote: `data/tags.json`, `data/coverage.json`, `fetched_at`, script names.
5. Do not change **Purpose** / **Назначение** or links unless asked.
6. Keep `README.md` and `README.ru.md` in sync.

## Add a new ecosystem repo

1. Add the name to `catalog/repos.list`.
2. Add a row to the tables in `README.md` and `README.ru.md`.
3. **`fetch_tags`** (MCP) or `./scripts/fetch-tags.sh`, then **`fcov_run`** per clone, then `fetch-coverage.sh` + `update-readme-versions.sh` (MCP `shell_run` or shell).

## Default branches

| Repo | GitHub default | Note |
|------|----------------|------|
| fmix, fhdl | `master` | TODO: rename to `main` |
| others | `main` | |

Scripts detect via `git remote show` / `ls-remote --symref`.

## Dependencies

`git`, `jq`, `gforth` ≥ 0.7.9. Preflight warns on pending `apt` upgrades and snap gforth. MCP additionally requires `fmcp` in Cursor `mcp.json` (`FMCP_HOME`, `FMIX_HOME`, `FLINT_HOME`, `FCOV_HOME`, `PATH`).
