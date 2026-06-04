# feco — каталог экосистемы VitaSound Forth

Экспериментальный набор инструментов и библиотек для Gforth, созданный с использованием ИИ. Цель — чтобы разработка на Forth соответствовала современным принципам: единый тулчейн (сборка, тесты, линт, покрытие), декларативные зависимости, воспроизводимые релизы и интеграция с IDE. В перспективе — применение ИИ-ассистентов непосредственно в цикле разработки на Forth: от написания кода до верификации через `fmix test`, `flint` и `fcov`.

Все репозитории — организация [VitaSound](https://github.com/VitaSound) на GitHub. Локально они обычно лежат рядом: `~/frules`, `~/fmix`, `~/flint`, …

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

| Проект | Назначение | Версия | Последнее обновление | Репозиторий |
|--------|------------|--------|----------------------|-------------|
| **fmix** | Сборка, пакетный менеджер и раннер тестов (`fmix new`, `packages.get`, `test`) | 0.7.2 | 2026-06-05 | [VitaSound/fmix](https://github.com/VitaSound/fmix) |
| **flint** | Линтер: предупреждения о дублирующихся определениях слов в `.4th` | 0.2.2 | 2026-05-24 | [VitaSound/flint](https://github.com/VitaSound/flint) |
| **fcov** | Сбор и отчёты по покрытию кода (console, JSON, LCOV, HTML) | 0.3.0 | 2026-05-24 | [VitaSound/fcov](https://github.com/VitaSound/fcov) |
| **fmcp** | MCP stdio-мост: `fmix`, `flint`, `fcov` из Cursor и других MCP-клиентов | 0.1.0 | 2026-06-05 | [VitaSound/fmcp](https://github.com/VitaSound/fmcp) |
| **fjson** | Минимальная запись JSON, read-lite и дерево узлов (MCP NDJSON, тулчейн) | 0.2.2 | 2026-06-05 | [VitaSound/fjson](https://github.com/VitaSound/fjson) |
| **fhdlgen** | Генератор HDL на Gforth: IR «проект → модуль → порт», emit Verilog | 0.3.1 | 2026-05-24 | [VitaSound/fhdlgen](https://github.com/VitaSound/fhdlgen) |
| **fsemver** | Парсер и матчер semver-требований (`~>`, `>=`, …) для `package.4th` | 0.1.1 | 2026-05-24 | [VitaSound/fsemver](https://github.com/VitaSound/fsemver) |
| **ttester** | Тестовый фреймворк Hayes/Ertl + расширения VitaSound (`T{ }T`, `expect-*`) | 1.2.1 | 2026-05-24 | [VitaSound/ttester](https://github.com/VitaSound/ttester) |
| **fenum** | Универсальные контейнеры (`ulist`, type-tag диспетчер в стиле Elixir Enum) | 0.1.1 | 2026-05-22 | [VitaSound/fenum](https://github.com/VitaSound/fenum) |
| **f** | Менеджер пакетов [theForthNet](https://theforth.net); слой совместимости | 0.2.4 | 2025-07-03 | [VitaSound/f](https://github.com/VitaSound/f) |
| **fhdl** | Ранний генератор Verilog из Forth-DSL (предшественник fhdlgen) | 0.1.0 | 2026-01-18 | [VitaSound/fhdl](https://github.com/VitaSound/fhdl) |
| **frules** | Сжатые правила Forth для Cursor и других ИИ-ассистентов | 0.1.2 | 2026-06-03 | [VitaSound/frules](https://github.com/VitaSound/frules) |

Версии — последний тег на GitHub, скрипт `./scripts/fetch-tags.sh` → [data/tags.json](data/tags.json). Инструкция для агента: [AGENTS.md](AGENTS.md).

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

- [frules/README.md](https://github.com/VitaSound/frules/blob/main/README.md) — установка правил, диалекты (`gforth` / `ans`), профили (`full` / `core`)
- [frules/AGENTS.md](https://github.com/VitaSound/frules/blob/main/AGENTS.md) — краткая сводка для агента
- [fmix/AGENTS.md](https://github.com/VitaSound/fmix/blob/main/AGENTS.md) — контекст для ИИ по всему тулчейну
- [fhdlgen/doc/ecosystem.md](https://github.com/VitaSound/fhdlgen/blob/main/doc/ecosystem.md) — подробный обзор стека, матрица совместимости, baseline покрытия
