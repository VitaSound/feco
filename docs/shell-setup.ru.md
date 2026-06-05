# Настройка shell — CLI-инструменты VitaSound

Канон для `~/.bashrc` / `~/.zshrc`. README каждого CLI-репозитория ссылается сюда.

## Формат

**Две строки на инструмент** — не объединяйте несколько `bin` в один `PATH`:

```bash
export FMIX_HOME="<install-dir>/fmix"
export PATH="$FMIX_HOME/bin:$PATH"
```

| Инструмент | Переменная | Проверка |
|------------|------------|----------|
| fmix | `FMIX_HOME` | `fmix version` |
| flint | `FLINT_HOME` | `flint version` |
| fcov | `FCOV_HOME` | `fcov version` |
| fmcp | `FMCP_HOME` | `fmcp version` |
| fhdlgen | `FHDLGEN_HOME` | `fhdlgen version` |

Библиотеки (**без** bashrc): frules, fsemver, ttester, fenum, f, fjson, fhdl.

## Каталог установки

`<install-dir>` — родитель клонов, **`FECO_WORKSPACE`** в [feco](../README.ru.md):

| Где лежит feco | Workspace | Пример `FMIX_HOME` |
|----------------|-----------|---------------------|
| `~/feco` | `~` | `$HOME/fmix` |
| `/opt/vitasound/feco` | `/opt/vitasound` | `/opt/vitasound/fmix` |

Клоны всегда **рядом с feco**, не обязательно в `$HOME`. Изолированный workspace не захламляет home.

## Массовая установка

Из [feco](https://github.com/VitaSound/feco):

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh          # последние теги (режим user)
./scripts/clone-ecosystem.sh --dev    # ветки main/master для разработки
```

Скрипт печатает готовый фрагмент для инструментов, которых ещё нет в профиле.

## Антипаттерн

**Не** используйте:

```bash
alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'
```

Только лаунчеры `bin/<tool>` — они корректно сбрасывают TTY (важно в WSL). См. [fmix README](https://github.com/VitaSound/fmix#shell-setup).

## MCP (fmcp)

В `mcp.json` Cursor можно задать `FMIX_HOME`, `FLINT_HOME`, `FCOV_HOME` явно. Пути в shell и в MCP `env` должны совпадать.
