# feco — инструкция для агента

Каталог экосистемы VitaSound Forth: `README.md` для людей, `data/tags.json` — версии с GitHub.

## Обновить каталог

```bash
cd /path/to/feco
./scripts/fetch-tags.sh
```

Скрипт для каждого репо из `catalog/repos.list` делает `git ls-remote --tags` и берёт **последний semver-тег** (`sort -V | tail -1`, префикс `v` снимается).

Проверка:

```bash
./scripts/fetch-tags.sh --table
jq '.repos.fmix.latest' data/tags.json
```

## Править README.md

1. Запустить `./scripts/fetch-tags.sh`.
2. В таблице **Каталог библиотек и инструментов** для каждой строки:
   - **Версия** ← `repos.<имя>.latest` из `data/tags.json` (если `null` — оставить `—`).
   - **Последнее обновление** — дату скрипт не тянет; при необходимости взять из локального клона:  
     `git -C ../<имя> log -1 --format=%cs $(git -C ../<имя> describe --tags --abbrev=0 2>/dev/null)`  
     или оставить без изменений.
3. В сноске под таблицей указать `data/tags.json` и поле `fetched_at`.
4. Не менять тексты «Назначение» и ссылки без запроса пользователя.

## Новый репозиторий в экосистеме

1. Имя в `catalog/repos.list`.
2. Строка в таблице `README.md`.
3. `./scripts/fetch-tags.sh` и обновить версию в таблице.

## Зависимости

`git`, `jq`.
