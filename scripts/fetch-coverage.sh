#!/usr/bin/env bash
# Definition coverage for ecosystem catalog.
#
# Default: Cov badge from $FECO_WORKSPACE/<repo>/README.md → data/coverage.json
#   ./scripts/fetch-coverage.sh
#   ./scripts/fetch-coverage.sh --table
#
# Optional: read .fcov/coverage.json from local clones (debug / legacy):
#   ./scripts/fetch-coverage.sh --local

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$FECO_ROOT/scripts/lib/common.sh"

OUT="$COVERAGE_JSON"
SOURCE_MODE="readme-badge"

while [ $# -gt 0 ]; do
  case "$1" in
    --table) TABLE=1; shift ;;
    --local) SOURCE_MODE="local-fcov"; shift ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

build_json_readme() {
  local fetched_at repo file pct entries=()
  fetched_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  while IFS= read -r repo; do
    file="$(repo_readme_path "$repo")"
    if [ ! -f "$file" ]; then
      echo "$repo... (no README.md)" >&2
      continue
    fi

    pct="$(repo_readme_cov_pct "$repo")"
    if [ -z "$pct" ]; then
      echo "$repo... (no Cov badge)" >&2
      entries+=("$(jq -n \
        --arg repo "$repo" \
        --arg org "$ORG" \
        '{key: $repo, value: {
          url: ("https://github.com/" + $org + "/" + $repo),
          coverage_pct: null,
          words_covered: null,
          words_total: null,
          source: "readme-badge"
        }}')")
      continue
    fi

    echo "$repo... ${pct}%" >&2
    entries+=("$(jq -n \
      --arg repo "$repo" \
      --arg org "$ORG" \
      --arg pct "$pct" \
      '{key: $repo, value: {
        url: ("https://github.com/" + $org + "/" + $repo),
        coverage_pct: ($pct | tonumber),
        words_covered: null,
        words_total: null,
        source: "readme-badge"
      }}')")
  done < <(read_repos)

  jq -n \
    --arg fetched_at "$fetched_at" \
    --arg org "$ORG" \
    --argjson items "$(printf '%s\n' "${entries[@]}" | jq -s .)" \
    '{
      fetched_at: $fetched_at,
      org: $org,
      method: "Cov badge in README.md (shields.io)",
      repos: ($items | map({(.key): .value}) | add // {})
    }'
}

build_json_local() {
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

if [ "$SOURCE_MODE" = local-fcov ]; then
  JSON="$(build_json_local)"
else
  JSON="$(build_json_readme)"
fi

if [ "${TABLE:-0}" = 1 ]; then
  echo "$JSON" | jq -r '.repos | to_entries[] | [.key, (.value.coverage_pct // "-"), (.value.source // "-")] | @tsv'
  exit 0
fi

mkdir -p "$(dirname "$OUT")"
echo "$JSON" | jq . >"$OUT"
echo "wrote $OUT" >&2
echo "$JSON" | jq -r '.repos | to_entries[] | "\(.key)\t\(.value.coverage_pct // "-")%\t\(.value.source // "-")"' >&2
