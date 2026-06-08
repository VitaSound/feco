#!/usr/bin/env bash
# scripts/tests/fetch-coverage_test.sh — readme badge parsing

set -euo pipefail

FECO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/demo"
cat >"$tmpdir/demo/README.md" <<'EOF'
# demo
[![Cov](https://img.shields.io/badge/Cov-42%25-yellow.svg)](https://example.com)
EOF

FECO_ROOT="$FECO_ROOT" FECO_WORKSPACE="$tmpdir" \
  bash -c '
    source "'"$FECO_ROOT"'/scripts/lib/common.sh"
    pct=$(repo_readme_cov_pct demo)
    [ "$pct" = 42 ]
  '

echo "fetch-coverage_test ok"
