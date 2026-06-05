#!/usr/bin/env bash
# Clone all VitaSound repos from catalog/repos.list into FECO_WORKSPACE.
#
#   ./scripts/clone-ecosystem.sh              # user mode → latest semver tag
#   ./scripts/clone-ecosystem.sh --dev      # dev mode → default branch (main/master)
#   ./scripts/clone-ecosystem.sh --check-only # preflight + bashrc preview only
#   ./scripts/clone-ecosystem.sh --print-bashrc
#
# Env: FECO_WORKSPACE, FECO_GITHUB_ORG, FECO_GIT_SCHEME (ssh|https), FECO_MODE (user|dev)

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$FECO_ROOT/scripts/lib/common.sh"

MODE="$(feco_mode)"
SKIP_PREFLIGHT=0
CHECK_ONLY=0
PRINT_BASHRC=0

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dev)            MODE=dev; FECO_MODE=dev ;;
    --https)          GIT_SCHEME=https; FECO_GIT_SCHEME=https ;;
    --workspace)      shift; FECO_WORKSPACE="${1:?--workspace requires DIR}" ;;
    --skip-preflight) SKIP_PREFLIGHT=1 ;;
    --check-only)     CHECK_ONLY=1 ;;
    --print-bashrc)   PRINT_BASHRC=1 ;;
    -h|--help)        usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

ws="$(feco_workspace)"
echo "feco root:  $FECO_ROOT" >&2
echo "workspace:  $ws" >&2
echo "git scheme: $GIT_SCHEME" >&2
echo "mode:       $MODE" >&2

if [ "$SKIP_PREFLIGHT" = 0 ]; then
  check_system_deps
  check_pending_patches
fi

if [ "$CHECK_ONLY" = 1 ] || [ "$PRINT_BASHRC" = 1 ]; then
  print_bashrc_snippet
  [ "$CHECK_ONLY" = 1 ] && exit 0
fi

if [ "$PRINT_BASHRC" = 1 ]; then
  exit 0
fi

cloned=0
skipped=0

while IFS= read -r repo; do
  dir="${ws%/}/$repo"
  if [ -d "$dir/.git" ]; then
    skipped=$((skipped + 1))
  else
    cloned=$((cloned + 1))
  fi
  clone_repo "$repo" "$MODE"
done < <(read_repos)

echo "" >&2
echo "Done: cloned=$cloned skipped=$skipped mode=$MODE workspace=$ws" >&2
print_bashrc_snippet
