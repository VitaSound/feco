# feco — каталог экосистемы VitaSound Forth

[English version](README.md)

Экспериментальный набор инструментов и библиотек для Gforth, созданный с использованием ИИ. Цель — чтобы разработка на Forth соответствовала современным принципам: единый тулчейн (сборка, тесты, линт, покрытие), декларативные зависимости, воспроизводимые релизы и интеграция с IDE. В перспективе — применение ИИ-ассистентов непосредственно в цикле разработки на Forth: от написания кода до верификации через `fmix test`, `flint` и `fcov`.

Все репозитории — организация [VitaSound](https://github.com/VitaSound) на GitHub. Локально они лежат **рядом с feco** в одном родительском каталоге (`FECO_WORKSPACE`): например `~/fmix` при feco в `~/feco`, или `/opt/vitasound/fmix` для изолированного окружения — см. [docs/shell-setup.ru.md](docs/shell-setup.ru.md).

**Установить всё:**

```bash
cd /path/to/feco
./scripts/clone-ecosystem.sh          # последние теги (режим user)
./scripts/clone-ecosystem.sh --dev    # main/master для разработки
./scripts/update-ecosystem.sh         # обновить теги, клоны, каталог, deps
```

![Forth и современный тулинг — иллюстрация к статье про fmix](assets/programming-languages-personified.png)

Статья, с которой начался этот стек — про [fmix](https://github.com/VitaSound/fmix):

- [FMix: a package manager for Forth](https://dev.to/ua3mqj/fmix-a-package-manager-for-forth-37ld) (English)
- [FMix: пакетный менеджер для Forth](https://dev.to/ua3mqj/fmix-pakietnyi-mieniedzhier-dlia-forth-o3p) (русский)

## Стек (кратко)

```
frules                                    ← правила Forth для ИИ-ассистентов
        │
fsemver · ttester · fenum · f             ← общие библиотеки
        │
fmix · flint · fcov · fmcp · fjson        ← инструментарий
        │
fhdlgen / fhdl                            ← прикладные генераторы HDL
```

## Каталог библиотек и инструментов

| Проект | Назначение | Версия | Последнее обновление | % покрытия | Репозиторий |
|--------|------------|--------|----------------------|------------|-------------|
| **frules** | Сжатые правила Forth для Cursor и других ИИ-ассистентов | 0.1.1 | 2026-05-27 | 2% | [VitaSound/frules](https://github.com/VitaSound/frules) |
| **fsemver** | Парсер и матчер semver-требований (`~>`, `>=`, …) для `package.4th` | 0.1.1 | 2026-05-24 | 100% | [VitaSound/fsemver](https://github.com/VitaSound/fsemver) |
| **ttester** | Тестовый фреймворк Hayes/Ertl + расширения VitaSound (`T{ }T`, `expect-*`) | 1.2.1 | 2026-05-24 | 29% | [VitaSound/ttester](https://github.com/VitaSound/ttester) |
| **fenum** | Универсальные контейнеры (`ulist`, type-tag диспетчер в стиле Elixir Enum) | 0.1.2 | 2026-06-08 | 98% | [VitaSound/fenum](https://github.com/VitaSound/fenum) |
| **f** | Менеджер пакетов [theForthNet](https://theforth.net); слой совместимости | 0.2.4 | 2025-07-03 | 8% | [VitaSound/f](https://github.com/VitaSound/f) |
| **fmix** | Сборка, пакетный менеджер и раннер тестов (`fmix new`, `packages.get`, `test`) | 0.8.0 | 2026-06-08 | 75% | [VitaSound/fmix](https://github.com/VitaSound/fmix) |
| **flint** | Линтер: предупреждения о дублирующихся определениях слов в `.4th` | 0.3.0 | 2026-06-08 | 87% | [VitaSound/flint](https://github.com/VitaSound/flint) |
| **fcov** | Сбор и отчёты по покрытию кода (console, JSON, LCOV, HTML) | 0.3.2 | 2026-06-08 | 81% | [VitaSound/fcov](https://github.com/VitaSound/fcov) |
| **fmcp** | MCP stdio-мост: `fmix`, `flint`, `fcov` из Cursor и других MCP-клиентов | 0.2.0 | 2026-06-08 | 71% | [VitaSound/fmcp](https://github.com/VitaSound/fmcp) |
| **fjson** | Минимальная запись JSON, read-lite и дерево узлов (MCP NDJSON, тулчейн) | 0.2.5 | 2026-06-08 | 100% | [VitaSound/fjson](https://github.com/VitaSound/fjson) |
| **fhdlgen** | Генератор HDL на Gforth: IR «проект → модуль → порт», emit Verilog | 0.3.1 | 2026-05-24 | 90% | [VitaSound/fhdlgen](https://github.com/VitaSound/fhdlgen) |
| **fhdl** | Ранний генератор Verilog из Forth-DSL (предшественник fhdlgen) | — | — | 76% | [VitaSound/fhdl](https://github.com/VitaSound/fhdl) |

Версии — последний тег на GitHub: `./scripts/fetch-tags.sh` → [data/tags.json](data/tags.json) (`fetched_at`: 2026-06-08T10:21:44Z). Покрытие (definition coverage, `fcov run fmix test`): `./scripts/fetch-coverage.sh` → [data/coverage.json](data/coverage.json) (`fetched_at`: 2026-06-08T10:22:38Z). Скрипты: `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh`. Shell: [docs/shell-setup.ru.md](docs/shell-setup.ru.md). Инструкция для агента: [AGENTS.ru.md](AGENTS.ru.md).

## Типичный рабочий цикл

**Новый проект:**

```bash
fmix new <имя>       # каркас: package.4th, tests/, .gitignore, …
cd <имя>
~/frules/install.sh . gforth   # правила Forth → .cursor/rules/
fmix packages.get
flint
fmix test
fcov run && fcov report   # опционально
```

**Существующий проект:**

```bash
cd <проект>
~/frules/install.sh . gforth   # если ещё не подключены правила
fmix packages.get    # зависимости из package.4th
flint                # линт (опционально)
fmix test            # *_test.4th
fcov run && fcov report   # покрытие (опционально)
```

**Cursor:** [frules](https://github.com/VitaSound/frules) — правила для ассистента при работе с `.4th` (симлинки в `.cursor/rules/`); [fmcp](https://github.com/VitaSound/fmcp) — MCP-сервер для `fmix` / `flint` / `fcov` из IDE. Подробнее: [frules/README.md](https://github.com/VitaSound/frules/blob/main/README.md), [fmcp/README.md](https://github.com/VitaSound/fmcp/blob/main/README.md).

## См. также

- [FMix: a package manager for Forth](https://dev.to/ua3mqj/fmix-a-package-manager-for-forth-37ld) · [FMix: пакетный менеджер для Forth](https://dev.to/ua3mqj/fmix-pakietnyi-mieniedzhier-dlia-forth-o3p) — статьи на DEV
- [frules/README.md](https://github.com/VitaSound/frules/blob/main/README.md) — установка правил, диалекты (`gforth` / `ans`), профили (`full` / `core`)
- [frules/AGENTS.md](https://github.com/VitaSound/frules/blob/main/AGENTS.md) — краткая сводка для агента
- [fmix/AGENTS.md](https://github.com/VitaSound/fmix/blob/main/AGENTS.md) — контекст для ИИ по всему тулчейну
- [fhdlgen/doc/ecosystem.md](https://github.com/VitaSound/fhdlgen/blob/main/doc/ecosystem.md) — подробный обзор стека, матрица совместимости, baseline покрытия
