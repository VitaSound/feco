#!/usr/bin/env bash
# Full ecosystem sync: tags.json, local clones, README catalog, fmix packages.get, bashrc hint.
#
#   ./scripts/update-ecosystem.sh              # user mode → latest tags
#   ./scripts/update-ecosystem.sh --dev        # dev mode → pull main/master
#   ./scripts/update-ecosystem.sh --no-readme
#   ./scripts/update-ecosystem.sh --no-packages
#   ./scripts/update-ecosystem.sh --no-clones
#   ./scripts/update-ecosystem.sh --print-bashrc

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$FECO_ROOT/scripts/lib/common.sh"

MODE="$(feco_mode)"
NO_README=0
NO_PACKAGES=0
NO_CLONES=0
PRINT_BASHRC=0

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dev)            MODE=dev; FECO_MODE=dev ;;
    --https)          GIT_SCHEME=https; FECO_GIT_SCHEME=https ;;
    --workspace)      shift; FECO_WORKSPACE="${1:?--workspace requires DIR}" ;;
    --no-readme)      NO_README=1 ;;
    --no-packages)    NO_PACKAGES=1 ;;
    --no-clones)      NO_CLONES=1 ;;
    --print-bashrc)   PRINT_BASHRC=1 ;;
    -h|--help)        usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

ws="$(feco_workspace)"
echo "feco root:  $FECO_ROOT" >&2
echo "workspace:  $ws" >&2
echo "mode:       $MODE" >&2

if [ "$PRINT_BASHRC" = 1 ]; then
  print_bashrc_snippet
  exit 0
fi

echo "==> fetch-tags" >&2
"$FECO_ROOT/scripts/fetch-tags.sh"

echo "==> fetch-coverage" >&2
"$FECO_ROOT/scripts/fetch-coverage.sh" || echo "[!] fetch-coverage skipped or partial (no local .fcov/ data)" >&2

if [ "$NO_CLONES" = 0 ]; then
  echo "==> sync local clones" >&2
  while IFS= read -r repo; do
    sync_repo_ref "$repo" "$MODE"
  done < <(read_repos)
fi

if [ "$NO_README" = 0 ]; then
  echo "==> update README versions" >&2
  "$FECO_ROOT/scripts/update-readme-versions.sh"
fi

if [ "$NO_PACKAGES" = 0 ]; then
  if ! command -v fmix >/dev/null 2>&1; then
    echo "[!] fmix not in PATH — skipping packages.get (see bashrc snippet below)" >&2
  else
    echo "==> fmix packages.get" >&2
    while IFS= read -r repo; do
      dir="${ws%/}/$repo"
      if [ -f "$dir/package.4th" ]; then
        echo "  packages.get in $repo" >&2
        (cd "$dir" && fmix packages.get) || echo "[!] packages.get failed in $repo" >&2
      fi
    done < <(read_repos)
  fi
fi

print_bashrc_snippet
echo "update-ecosystem.sh complete." >&2
