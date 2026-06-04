# feco — agent instructions

[Russian version](AGENTS.ru.md)

Catalog of the VitaSound Forth ecosystem: `README.md` for humans, `data/tags.json` for versions from GitHub.

## Refresh the catalog

```bash
cd /path/to/feco
./scripts/fetch-tags.sh
```

For each repo in `catalog/repos.list`, the script runs `git ls-remote --tags` and picks the **latest semver tag** (`sort -V | tail -1`, strips a leading `v`).

Verify:

```bash
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

## Update README

1. Run `./scripts/fetch-tags.sh`.
2. In the **Library and tool catalog** table (`README.md` and `README.ru.md`), for each row:
   - **Version** / **Версия** ← `repos.<name>.latest` from `data/tags.json` (if `null`, use `—`).
   - **Last updated** / **Последнее обновление** — the script does not fetch dates; if needed, from a local clone:  
     `git -C ../<name> log -1 --format=%cs $(git -C ../<name> describe --tags --abbrev=0 2>/dev/null)`  
     or leave unchanged.
3. In the footnote under the table, mention `data/tags.json` and `fetched_at`.
4. Do not change **Purpose** / **Назначение** text or links unless the user asks.
5. Keep `README.md` and `README.ru.md` in sync.

## Add a new ecosystem repo

1. Add the name to `catalog/repos.list`.
2. Add a row to the tables in `README.md` and `README.ru.md`.
3. Run `./scripts/fetch-tags.sh` and update the version column.

## Dependencies

`git`, `jq`.
