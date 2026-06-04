# feco — VitaSound Forth ecosystem catalog

[Russian version](README.ru.md)

An experimental toolkit and library set for Gforth, built with AI assistance. The goal is modern Forth development: a unified toolchain (build, tests, lint, coverage), declarative dependencies, reproducible releases, and IDE integration. Long term — AI assistants in the Forth dev loop, from writing code to verification via `fmix test`, `flint`, and `fcov`.

All repositories live under [VitaSound](https://github.com/VitaSound) on GitHub. Locally they usually sit side by side: `~/frules`, `~/fmix`, `~/flint`, …

![Forth and modern tooling — illustration for the fmix article](assets/programming-languages-personified.png)

The article that started this stack — about [fmix](https://github.com/VitaSound/fmix):

- [FMix: a package manager for Forth](https://dev.to/ua3mqj/fmix-a-package-manager-for-forth-37ld) (English)
- [FMix: пакетный менеджер для Forth](https://dev.to/ua3mqj/fmix-pakietnyi-mieniedzhier-dlia-forth-o3p) (Russian)

## Stack (overview)

```
frules                                    ← Forth rules for AI assistants
        │
fsemver · ttester · fenum · f             ← shared libraries
        │
fmix · flint · fcov · fmcp · fjson        ← tooling
        │
fhdlgen / fhdl                            ← HDL generators
```

## Library and tool catalog

| Project | Purpose | Version | Last updated | Repository |
|---------|---------|---------|--------------|------------|
| **fmix** | Build tool, package manager, test runner (`fmix new`, `packages.get`, `test`) | 0.7.2 | 2026-06-05 | [VitaSound/fmix](https://github.com/VitaSound/fmix) |
| **flint** | Linter: warns on duplicate word definitions in `.4th` | 0.2.2 | 2026-05-24 | [VitaSound/flint](https://github.com/VitaSound/flint) |
| **fcov** | Code coverage collection and reports (console, JSON, LCOV, HTML) | 0.3.0 | 2026-05-24 | [VitaSound/fcov](https://github.com/VitaSound/fcov) |
| **fmcp** | MCP stdio bridge: `fmix`, `flint`, `fcov` from Cursor and other MCP clients | 0.1.0 | 2026-06-05 | [VitaSound/fmcp](https://github.com/VitaSound/fmcp) |
| **fjson** | Minimal JSON write, read-lite, and node tree (MCP NDJSON, toolchain) | 0.2.2 | 2026-06-05 | [VitaSound/fjson](https://github.com/VitaSound/fjson) |
| **fhdlgen** | Gforth HDL generator: IR project → module → port, Verilog emit | 0.3.1 | 2026-05-24 | [VitaSound/fhdlgen](https://github.com/VitaSound/fhdlgen) |
| **fsemver** | Semver requirement parser and matcher (`~>`, `>=`, …) for `package.4th` | 0.1.1 | 2026-05-24 | [VitaSound/fsemver](https://github.com/VitaSound/fsemver) |
| **ttester** | Hayes/Ertl test framework + VitaSound extensions (`T{ }T`, `expect-*`) | 1.2.1 | 2026-05-24 | [VitaSound/ttester](https://github.com/VitaSound/ttester) |
| **fenum** | Generic containers (`ulist`, Elixir Enum–style type-tag dispatch) | 0.1.1 | 2026-05-22 | [VitaSound/fenum](https://github.com/VitaSound/fenum) |
| **f** | [theForthNet](https://theforth.net) package manager; compatibility layer | 0.2.4 | 2025-07-03 | [VitaSound/f](https://github.com/VitaSound/f) |
| **fhdl** | Early Verilog generator from Forth DSL (fhdlgen predecessor) | 0.1.0 | 2026-01-18 | [VitaSound/fhdl](https://github.com/VitaSound/fhdl) |
| **frules** | Compact Forth rules for Cursor and other AI assistants | 0.1.2 | 2026-06-03 | [VitaSound/frules](https://github.com/VitaSound/frules) |

Versions are the latest Git tag on GitHub: `./scripts/fetch-tags.sh` → [data/tags.json](data/tags.json). Agent instructions: [AGENTS.md](AGENTS.md).

## Typical workflow

**New project:**

```bash
fmix new <name>       # scaffold: package.4th, tests/, .gitignore, …
cd <name>
~/frules/install.sh . gforth   # Forth rules → .cursor/rules/
fmix packages.get
flint
fmix test
fcov run && fcov report   # optional
```

**Existing project:**

```bash
cd <project>
~/frules/install.sh . gforth   # if rules not installed yet
fmix packages.get    # dependencies from package.4th
flint                # lint (optional)
fmix test            # *_test.4th
fcov run && fcov report   # coverage (optional)
```

**Cursor:** [frules](https://github.com/VitaSound/frules) — assistant rules for `.4th` (symlinks in `.cursor/rules/`); [fmcp](https://github.com/VitaSound/fmcp) — MCP server for `fmix` / `flint` / `fcov` from the IDE. See [frules/README.md](https://github.com/VitaSound/frules/blob/main/README.md), [fmcp/README.md](https://github.com/VitaSound/fmcp/blob/main/README.md).

## See also

- [FMix: a package manager for Forth](https://dev.to/ua3mqj/fmix-a-package-manager-for-forth-37ld) · [FMix: пакетный менеджер для Forth](https://dev.to/ua3mqj/fmix-pakietnyi-mieniedzhier-dlia-forth-o3p) — DEV articles
- [frules/README.md](https://github.com/VitaSound/frules/blob/main/README.md) — installing rules, dialects (`gforth` / `ans`), profiles (`full` / `core`)
- [frules/AGENTS.md](https://github.com/VitaSound/frules/blob/main/AGENTS.md) — short agent summary
- [fmix/AGENTS.md](https://github.com/VitaSound/fmix/blob/main/AGENTS.md) — AI context for the whole toolchain
- [fhdlgen/doc/ecosystem.md](https://github.com/VitaSound/fhdlgen/blob/main/doc/ecosystem.md) — detailed stack overview, compatibility matrix, coverage baseline
