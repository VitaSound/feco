# feco — инструкция для агента

[English version](AGENTS.md)

Каталог экосистемы VitaSound Forth: `README.ru.md` для людей, `data/tags.json` — версии с GitHub.

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

## Править README

1. Запустить `./scripts/fetch-tags.sh`.
2. В таблице **Каталог библиотек и инструментов** (`README.ru.md` и `README.md`) для каждой строки:
   - **Версия** / **Version** ← `repos.<имя>.latest` из `data/tags.json` (если `null` — оставить `—`).
   - **Последнее обновление** / **Last updated** — дату скрипт не тянет; при необходимости взять из локального клона:  
     `git -C ../<имя> log -1 --format=%cs $(git -C ../<имя> describe --tags --abbrev=0 2>/dev/null)`  
     или оставить без изменений.
3. В сноске под таблицей указать `data/tags.json` и поле `fetched_at`.
4. Не менять тексты «Назначение» / **Purpose** и ссылки без запроса пользователя.
5. Обновлять оба README (`README.md` и `README.ru.md`) синхронно.

## Новый репозиторий в экосистеме

1. Имя в `catalog/repos.list`.
2. Строка в таблицах `README.md` и `README.ru.md`.
3. `./scripts/fetch-tags.sh` и обновить версию в таблице.

## Зависимости

`git`, `jq`.
