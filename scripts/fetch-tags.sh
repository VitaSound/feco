#!/usr/bin/env bash
# Теги с GitHub по списку catalog/repos.list → data/tags.json
#
#   ./scripts/fetch-tags.sh
#   ./scripts/fetch-tags.sh --table

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$ROOT/catalog/repos.list"
OUT="$ROOT/data/tags.json"
ORG="${FECO_GITHUB_ORG:-VitaSound}"

repo_tags() {
  local repo=$1
  git ls-remote --tags "https://github.com/${ORG}/${repo}.git" 2>/dev/null \
    | grep -v '\^{}$' \
    | awk -F/ '{print $NF}' \
    | sed 's/^v//' \
    | grep -E '^[0-9]' \
    | sort -V
}

read_repos() {
  grep -v '^[[:space:]]*#' "$CATALOG" | grep -v '^[[:space:]]*$'
}

build_json() {
  local fetched_at repo tags latest entries=()
  fetched_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  while IFS= read -r repo; do
    echo "$repo..." >&2
    tags="$(repo_tags "$repo" | jq -R . | jq -s .)"
    latest="$(repo_tags "$repo" | tail -1)"
    entries+=("$(jq -n \
      --arg repo "$repo" \
      --arg org "$ORG" \
      --argjson tags "$tags" \
      --arg latest "$latest" \
      '{key: $repo, value: {
        url: ("https://github.com/" + $org + "/" + $repo),
        tags: $tags,
        latest: (if $latest == "" then null else $latest end)
      }}')")
  done < <(read_repos)

  jq -n \
    --arg fetched_at "$fetched_at" \
    --arg org "$ORG" \
    --argjson items "$(printf '%s\n' "${entries[@]}" | jq -s .)" \
    '{fetched_at: $fetched_at, org: $org, repos: ($items | map({(.key): .value}) | add)}'
}

JSON="$(build_json)"

if [ "${1:-}" = --table ]; then
  echo "$JSON" | jq -r '.repos | to_entries[] | [.key, (.value.latest // "-"), (.value.tags | length)] | @tsv'
  exit 0
fi

mkdir -p "$(dirname "$OUT")"
echo "$JSON" | jq . >"$OUT"
echo "wrote $OUT" >&2
echo "$JSON" | jq -r '.repos | to_entries[] | "\(.key)\t\(.value.latest // "-")\t\(.value.tags | length) tags"' >&2
