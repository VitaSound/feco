#!/usr/bin/env bash
# Update Version/Last updated columns in README.md and README.ru.md from data/tags.json.
#
#   ./scripts/update-readme-versions.sh

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$FECO_ROOT/scripts/lib/common.sh"

[ -f "$TAGS_JSON" ] || {
  echo "ERROR: $TAGS_JSON not found — run ./scripts/fetch-tags.sh first" >&2
  exit 1
}

FETCHED_AT="$(jq -r '.fetched_at' "$TAGS_JSON")"

update_row_in_file() {
  local file=$1 repo=$2 ver=$3 date=$4

  export PERL_REPO="$repo" PERL_VER="$ver" PERL_DATE="$date"
  perl -i -pe '
    if (/^\| \*\*\Q$ENV{PERL_REPO}\E\*\* \|/) {
      s/^(\| \*\*\Q$ENV{PERL_REPO}\E\*\* \| [^|]+ \|) [^|]+ (\|) [^|]+ (\|)/$1 $ENV{PERL_VER} $2 $ENV{PERL_DATE} $3/;
    }
  ' "$file"
}

update_footnote() {
  local file=$1
  export PERL_FETCHED_AT="$FETCHED_AT"
  if [[ "$file" == *".ru.md" ]]; then
    perl -i -pe '
      if (/Версии — последний тег/) {
        $_ = "Версии — последний тег на GitHub: `./scripts/fetch-tags.sh` → [data/tags.json](data/tags.json) (`fetched_at`: $ENV{PERL_FETCHED_AT}). Скрипты: `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh`. Shell: [docs/shell-setup.ru.md](docs/shell-setup.ru.md). Инструкция для агента: [AGENTS.ru.md](AGENTS.ru.md).\n";
      }
    ' "$file"
  else
    perl -i -pe '
      if (/Versions are the latest Git tag/) {
        $_ = "Versions are the latest Git tag on GitHub: `./scripts/fetch-tags.sh` → [data/tags.json](data/tags.json) (`fetched_at`: $ENV{PERL_FETCHED_AT}). Scripts: `./scripts/clone-ecosystem.sh`, `./scripts/update-ecosystem.sh`. Shell: [docs/shell-setup.md](docs/shell-setup.md). Agent instructions: [AGENTS.md](AGENTS.md).\n";
      }
    ' "$file"
  fi
}

update_readme_file() {
  local file=$1 repo ver date

  [ -f "$file" ] || { echo "skip missing $file" >&2; return 0; }

  while IFS= read -r repo; do
    ver="$(jq -r --arg r "$repo" '.repos[$r].latest // "—"' "$TAGS_JSON")"
    [ "$ver" = "null" ] && ver="—"
    date="$(repo_last_updated_date "$repo")"
    [ -n "$date" ] || date="—"

    if ! grep -qF "| **${repo}** |" "$file"; then
      echo "[!] no table row for $repo in $file" >&2
      continue
    fi

    update_row_in_file "$file" "$repo" "$ver" "$date"
    echo "  $repo → $ver ($date) in $(basename "$file")" >&2
  done < <(read_repos)

  update_footnote "$file"
}

echo "Updating README tables (fetched_at=$FETCHED_AT)..." >&2
update_readme_file "$FECO_ROOT/README.md"
update_readme_file "$FECO_ROOT/README.ru.md"
echo "done." >&2
