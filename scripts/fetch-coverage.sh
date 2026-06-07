#!/usr/bin/env bash
# Definition coverage from local clones: .fcov/coverage.json → data/coverage.json
#
#   ./scripts/fetch-coverage.sh
#   ./scripts/fetch-coverage.sh --table
#
# Requires ecosystem clones under FECO_WORKSPACE with fcov run fmix test already done.

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$FECO_ROOT/scripts/lib/common.sh"

OUT="$COVERAGE_JSON"

build_json() {
  local fetched_at repo file pct covered total entries=()
  fetched_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  while IFS= read -r repo; do
    file="$(repo_coverage_json_path "$repo")"
    if [ ! -f "$file" ]; then
      echo "$repo... (no .fcov/coverage.json)" >&2
      continue
    fi

    pct="$(repo_coverage_pct "$repo")"
    covered="$(jq -r '.summary.words_covered // empty' "$file")"
    total="$(jq -r '.summary.words_total // empty' "$file")"
    echo "$repo... ${pct:-?}%" >&2

    entries+=("$(jq -n \
      --arg repo "$repo" \
      --arg org "$ORG" \
      --arg pct "$pct" \
      --arg covered "$covered" \
      --arg total "$total" \
      '{key: $repo, value: {
        url: ("https://github.com/" + $org + "/" + $repo),
        coverage_pct: (if $pct == "" then null else ($pct | tonumber) end),
        words_covered: (if $covered == "" then null else ($covered | tonumber) end),
        words_total: (if $total == "" then null else ($total | tonumber) end),
        source: ".fcov/coverage.json"
      }}')")
  done < <(read_repos)

  jq -n \
    --arg fetched_at "$fetched_at" \
    --arg org "$ORG" \
    --argjson items "$(printf '%s\n' "${entries[@]}" | jq -s .)" \
    '{
      fetched_at: $fetched_at,
      org: $org,
      method: "fcov run fmix test → .fcov/coverage.json (definition coverage)",
      repos: ($items | map({(.key): .value}) | add // {})
    }'
}

JSON="$(build_json)"

if [ "${1:-}" = --table ]; then
  echo "$JSON" | jq -r '.repos | to_entries[] | [.key, (.value.coverage_pct // "-"), (.value.words_covered // "-"), (.value.words_total // "-")] | @tsv'
  exit 0
fi

mkdir -p "$(dirname "$OUT")"
echo "$JSON" | jq . >"$OUT"
echo "wrote $OUT" >&2
echo "$JSON" | jq -r '.repos | to_entries[] | "\(.key)\t\(.value.coverage_pct // "-")%\t\(.value.words_covered // "-")/\(.value.words_total // "-")"' >&2
