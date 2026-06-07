# feco — инструкция для агента

[English version](AGENTS.md)

Каталог экосистемы VitaSound Forth: `README.ru.md` для людей, `data/tags.json` — версии с GitHub, `data/coverage.json` — definition coverage из локальных прогонов `fcov`.

## MCP (предпочтительно для агента)

Использовать MCP-сервер **`vitasound-forth`** (Cursor: Settings → MCP). Имена инструментов ниже — **не** shell-команды (`fmix test`, `fcov run`, …).

**`project_root`** для работы с каталогом feco: абсолютный путь к этому репо (например `/home/sea/feco`). Для покрытия по библиотеке: абсолютный путь к клону в **`FECO_WORKSPACE`** (по умолчанию — родитель feco, например `/home/sea/fmix`).

| MCP tool | В feco | Заметки |
|----------|--------|---------|
| `mcp_ping` | Проверка сессии до/после пакетной работы | Без аргументов |
| `fetch_tags` | Обновить **`data/tags.json`** | Запускает `./scripts/fetch-tags.sh` в `project_root` |
| `fcov_run` | `fcov run fmix test` в одном репо экосистемы | Один репо на вызов; опционально `timeout_seconds` (по умолчанию 300) |
| `fcov_report` | JSON покрытия по одному репо | После `fcov_run` |
| `gforth_eval` | Быстрые проверки на Gforth | `project_root`, `source` |
| `shell_run` | Скрипты **без** отдельного MCP-инструмента | См. таблицу fallback ниже |

**Не** вызывать `./scripts/fetch-tags.sh`, `fcov run`, `fmix test` из shell, если есть соответствующий MCP-инструмент и сервер подключён.

Вызывать MCP **по одному** (без параллельных `tools/call`). Между репо при серии **`fcov_run`** — **`mcp_ping`**. При обрыве (`Connection closed`) — перезапуск MCP в Settings; лог: `$FMCP_HOME/.fmcp/serve.log`.

### Обновить таблицу каталога (workflow через MCP)

Типичная последовательность, когда пользователь просит обновить версии / покрытие в README:

1. **`mcp_ping`**
2. **`fetch_tags`** — `project_root` = корень feco → пишет `data/tags.json`
3. **`mcp_ping`**
4. **`fcov_run`** — для каждого репо из `catalog/repos.list`, у которого есть `package.4th` в `FECO_WORKSPACE/<имя>`; `project_root` = этот клон (в той же сессии не вызывать `flint_lint`)
5. **`mcp_ping`** (между репо при длинном batch)
6. **`shell_run`** — `project_root` = корень feco, команда:
   `./scripts/fetch-coverage.sh && ./scripts/update-readme-versions.sh`
7. **`mcp_ping`**

`fetch-coverage.sh` собирает `.fcov/coverage.json` из локальных клонов; `update-readme-versions.sh` обновляет `README.md` / `README.ru.md` из `data/tags.json` + `data/coverage.json`.

Опционально: **`gforth_eval`** на feco или клоне; **`fcov_report`** по одному репо для сырого JSON.

### MCP vs shell (fallback)

| Задача | Предпочтительно MCP | Shell fallback (нет MCP / настройка клонов) |
|--------|---------------------|---------------------------------------------|
| Теги экосистемы → `data/tags.json` | `fetch_tags` | `./scripts/fetch-tags.sh` |
| Покрытие одного репо | `fcov_run` | `cd $repo && fcov run fmix test` |
| Сводка покрытия + колонки README | `shell_run` (см. workflow выше) | те же скрипты |
| Клон / sync всех репо | — | `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh` |

Скрипты остаются **источником правды** для CI и людей; MCP оборачивает их где указано. Подробнее: [fmcp/AGENTS.md](https://github.com/VitaSound/fmcp/blob/main/AGENTS.md).

## Скачать экосистему

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh              # режим user → последние semver-теги
./scripts/clone-ecosystem.sh --dev        # режим dev → main/master (для коммитов)
./scripts/clone-ecosystem.sh --check-only # preflight + превью bashrc
```

Клоны попадают в **`FECO_WORKSPACE`** (по умолчанию — родитель feco). Если feco в `~/feco`, клоны в `~/fmix`, `~/frules`, … Если feco в `/opt/vitasound/feco` — клоны в `/opt/vitasound/fmix`, … — изолированное окружение, home не захламляется.

- **SSH по умолчанию** (`git@github.com:VitaSound/<repo>.git`); `--https` для HTTPS.
- **user** (по умолчанию): checkout последнего semver-тега.
- **dev** (`--dev`): checkout и pull default branch (`main`; у fmix/fhdl пока `master`).

Настройка shell после клона: [docs/shell-setup.ru.md](docs/shell-setup.ru.md).

## Обновить экосистему

```bash
./scripts/update-ecosystem.sh              # tags.json + клоны + README + packages.get
./scripts/update-ecosystem.sh --dev        # pull веток вместо тегов
./scripts/update-ecosystem.sh --no-packages
```

Агент с MCP: workflow **«Обновить таблицу каталога»** вместо ручного повторения шагов; `update-ecosystem.sh` — когда нужен полный sync клонов или MCP недоступен.

## Обновить каталог (только теги)

**Агент:** `fetch_tags`, `project_root` = корень feco.

**Человек / CI:**

```bash
./scripts/fetch-tags.sh
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

Для каждого репо из `catalog/repos.list` — `git ls-remote --tags`, последний semver (`sort -V | tail -1`, префикс `v` снимается).

## Обновить покрытие (локальные клоны)

После **`fcov_run`** по каждому клону (MCP) — агрегация:

```bash
./scripts/fetch-coverage.sh
./scripts/fetch-coverage.sh --table
jq '.repos.fjson.coverage_pct' data/coverage.json
```

Читает `FECO_WORKSPACE/<repo>/.fcov/coverage.json`. Репо без файла не попадают в `data/coverage.json`; в README — `—`.

## Править README

`./scripts/update-readme-versions.sh` (также из `update-ecosystem.sh` и через MCP `shell_run`) обновляет колонки версий и покрытия. Вручную:

1. **Версия** ← `repos.<имя>.latest` (если `null` — `—`).
2. **Последнее обновление** — из локального клона в `FECO_WORKSPACE/<имя>`, если есть.
3. **% покрытия** ← `data/coverage.json` → `repos.<имя>.coverage_pct` (если нет — `—`). Только definition coverage через `fcov run fmix test`.
4. Сноска: `data/tags.json`, `data/coverage.json`, `fetched_at`, имена скриптов.
5. Не менять «Назначение» / **Purpose** и ссылки без запроса.
6. Синхронно `README.md` и `README.ru.md`.

## Новый репозиторий в экосистеме

1. Имя в `catalog/repos.list`.
2. Строка в таблицах `README.md` и `README.ru.md`.
3. **`fetch_tags`** (MCP) или `./scripts/fetch-tags.sh`, затем **`fcov_run`** по клонам, затем `fetch-coverage.sh` + `update-readme-versions.sh` (MCP `shell_run` или shell).

## Ветки по умолчанию

| Репо | GitHub default | Примечание |
|------|----------------|------------|
| fmix, fhdl | `master` | TODO: переименовать в `main` |
| остальные | `main` | |

Скрипты определяют через `git remote show` / `ls-remote --symref`.

## Зависимости

`git`, `jq`, `gforth` ≥ 0.7.9. Preflight предупреждает о доступных обновлениях `apt` и gforth из snap. Для MCP дополнительно нужен `fmcp` в Cursor `mcp.json` (`FMCP_HOME`, `FMIX_HOME`, `FLINT_HOME`, `FCOV_HOME`, `PATH`).
