# feco — инструкция для агента

[English version](AGENTS.md)

Каталог экосистемы VitaSound Forth: `README.ru.md` для людей, `data/tags.json` — версии с GitHub, `data/coverage.json` — definition coverage из **Cov-badge** в README локальных клонов.

## MCP (предпочтительно для агента)

Использовать MCP-сервер **`vitasound-forth`** (Cursor: Settings → MCP). Имена инструментов ниже — **не** shell-команды (`fmix test`, `fcov run`, …).

**`project_root`** для работы с каталогом feco: абсолютный путь к этому репо (например `/home/sea/feco`). Для работы внутри библиотеки: абсолютный путь к клону в **`FECO_WORKSPACE`** (по умолчанию — родитель feco, например `/home/sea/fmix`).

| MCP tool | В feco | Заметки |
|----------|--------|---------|
| `mcp_ping` | Проверка сессии до/после пакетной работы | Без аргументов |
| `fetch_tags` | Обновить **`data/tags.json`** | Запускает `./scripts/fetch-tags.sh` в `project_root` |
| `fmix_check` | Quality gate в одном репо экосистемы | `stage`, опционально `fail_under`, `no_flint`, `no_fcov` |
| `fcov_run` | `fcov run fmix test` в одном репо (только разработка) | Не для обновления каталога |
| `fcov_report` | JSON покрытия по одному репо | После `fcov_run` в этом репо |
| `gforth_eval` | Быстрые проверки на Gforth | `project_root`, `source` |
| `shell_run` | Скрипты **без** отдельного MCP-инструмента | См. таблицу fallback ниже |

**Не** вызывать `./scripts/fetch-tags.sh` или `fmix check` из shell, если есть соответствующий MCP-инструмент и сервер подключён.

Вызывать MCP **по одному** (без параллельных `tools/call`). Между тяжёлыми вызовами — **`mcp_ping`**. При обрыве (`Connection closed`) — перезапуск MCP в Settings; лог: `$FMCP_HOME/.fmcp/serve.log`.

### Обновить таблицу каталога (workflow через MCP)

Типичная последовательность, когда пользователь просит обновить версии / покрытие в README:

1. **`mcp_ping`**
2. **`fetch_tags`** — `project_root` = корень feco → пишет `data/tags.json`
3. **`mcp_ping`**
4. **`shell_run`** — `project_root` = корень feco, команда:
   `./scripts/fetch-coverage.sh && ./scripts/update-readme-versions.sh`
5. **`mcp_ping`**

`fetch-coverage.sh` читает **Cov-badge** из `$FECO_WORKSPACE/<repo>/README.md` (`source: readme-badge`). Каждое репо поддерживает свой badge после `fmix check` / релиза — feco **не** запускает пакетный `fcov` по клонам.

Опционально: **`gforth_eval`** на feco или клоне; **`fcov_run`** только при разработке внутри одного репо.

### MCP vs shell (fallback)

| Задача | Предпочтительно MCP | Shell fallback (нет MCP / настройка клонов) |
|--------|---------------------|---------------------------------------------|
| Теги экосистемы → `data/tags.json` | `fetch_tags` | `./scripts/fetch-tags.sh` |
| Сводка покрытия + колонки README | `shell_run` (см. workflow выше) | `fetch-coverage.sh` + `update-readme-versions.sh` |
| Quality gate в одном репо | `fmix_check` | `fmix check` в клоне |
| Клон / sync всех репо | — | `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh` |

Скрипты остаются **источником правды** для CI и людей; MCP оборачивает их где указано. Подробнее: [fmcp/AGENTS.md](https://github.com/VitaSound/fmcp/blob/main/AGENTS.md).

## Скачать экосистему

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh              # режим user → последние semver-теги
./scripts/clone-ecosystem.sh --dev        # режим dev → main (для коммитов)
./scripts/clone-ecosystem.sh --check-only # preflight + превью bashrc
```

Клоны попадают в **`FECO_WORKSPACE`** (по умолчанию — родитель feco).

- **SSH по умолчанию**; `--https` для HTTPS.
- **user** (по умолчанию): checkout последнего semver-тега.
- **dev** (`--dev`): checkout и pull ветки `main`.

Настройка shell после клона: [docs/shell-setup.ru.md](docs/shell-setup.ru.md).

## Обновить экосистему

```bash
./scripts/update-ecosystem.sh
./scripts/update-ecosystem.sh --dev
./scripts/update-ecosystem.sh --no-packages
```

Агент с MCP: workflow **«Обновить таблицу каталога»** вместо ручного повторения шагов.

## Обновить каталог (только теги)

**Агент:** `fetch_tags`, `project_root` = корень feco.

## Обновить покрытие (badge в README)

**По умолчанию** — без пакетного `fcov run`:

```bash
./scripts/fetch-coverage.sh
./scripts/fetch-coverage.sh --table
```

Читает `badge/Cov-NN%` из `$FECO_WORKSPACE/<repo>/README.md`. Без badge → `coverage_pct: null` → в таблице `—`.

**Отладка:** `./scripts/fetch-coverage.sh --local` читает `.fcov/coverage.json`.

## Править README

`./scripts/update-readme-versions.sh` обновляет колонки версий и покрытия.

## Новый репозиторий в экосистеме

1. Имя в `catalog/repos.list`.
2. Строка в таблицах `README.md` и `README.ru.md`.
3. **`fetch_tags`**, затем `fetch-coverage.sh` + `update-readme-versions.sh`.

## Ветки по умолчанию

| Репо | GitHub default |
|------|----------------|
| fmix, fhdl | `main` |
| остальные | `main` |

## Зависимости

`git`, `jq`, `gforth` ≥ 0.7.9. Для MCP: `fmcp` в Cursor `mcp.json`.
