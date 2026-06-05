# feco — инструкция для агента

[English version](AGENTS.md)

Каталог экосистемы VitaSound Forth: `README.ru.md` для людей, `data/tags.json` — версии с GitHub.

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

## Обновить каталог (только теги)

```bash
./scripts/fetch-tags.sh
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

Для каждого репо из `catalog/repos.list` — `git ls-remote --tags`, последний semver (`sort -V | tail -1`, префикс `v` снимается).

## Править README

`./scripts/update-readme-versions.sh` (также из `update-ecosystem.sh`) обновляет колонки версий из `data/tags.json`. Вручную:

1. **Версия** ← `repos.<имя>.latest` (если `null` — `—`).
2. **Последнее обновление** — из локального клона в `FECO_WORKSPACE/<имя>`, если есть.
3. Сноска: `data/tags.json`, `fetched_at`, имена скриптов.
4. Не менять «Назначение» / **Purpose** и ссылки без запроса.
5. Синхронно `README.md` и `README.ru.md`.

## Новый репозиторий в экосистеме

1. Имя в `catalog/repos.list`.
2. Строка в таблицах `README.md` и `README.ru.md`.
3. `./scripts/fetch-tags.sh` и `./scripts/update-readme-versions.sh`.

## Ветки по умолчанию

| Репо | GitHub default | Примечание |
|------|----------------|------------|
| fmix, fhdl | `master` | TODO: переименовать в `main` |
| остальные | `main` | |

Скрипты определяют через `git remote show` / `ls-remote --symref`.

## Зависимости

`git`, `jq`, `gforth` ≥ 0.7.9. Preflight предупреждает о доступных обновлениях `apt` и gforth из snap.
