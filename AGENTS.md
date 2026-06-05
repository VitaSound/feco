# feco — agent instructions

[Russian version](AGENTS.ru.md)

Catalog of the VitaSound Forth ecosystem: `README.md` for humans, `data/tags.json` for versions from GitHub.

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

## Refresh the catalog (tags only)

```bash
./scripts/fetch-tags.sh
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

For each repo in `catalog/repos.list`, the script runs `git ls-remote --tags` and picks the **latest semver tag** (`sort -V | tail -1`, strips a leading `v`).

## Update README

`./scripts/update-readme-versions.sh` (also run from `update-ecosystem.sh`) updates version columns from `data/tags.json`. Manual rules:

1. **Version** / **Версия** ← `repos.<name>.latest` (if `null`, use `—`).
2. **Last updated** / **Последнее обновление** — from local clone at `FECO_WORKSPACE/<name>` when present.
3. Footnote: `data/tags.json`, `fetched_at`, script names.
4. Do not change **Purpose** / **Назначение** or links unless asked.
5. Keep `README.md` and `README.ru.md` in sync.

## Add a new ecosystem repo

1. Add the name to `catalog/repos.list`.
2. Add a row to the tables in `README.md` and `README.ru.md`.
3. Run `./scripts/fetch-tags.sh` and `./scripts/update-readme-versions.sh`.

## Default branches

| Repo | GitHub default | Note |
|------|----------------|------|
| fmix, fhdl | `master` | TODO: rename to `main` |
| others | `main` | |

Scripts detect via `git remote show` / `ls-remote --symref`.

## Dependencies

`git`, `jq`, `gforth` ≥ 0.7.9. Preflight warns on pending `apt` upgrades and snap gforth.
