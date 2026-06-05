# scripts/lib/common.sh — shared helpers for feco ecosystem scripts.
# Source from other scripts; do not execute directly.

: "${FECO_ROOT:?FECO_ROOT must be set before sourcing common.sh}"

CATALOG="${FECO_ROOT}/catalog/repos.list"
TAGS_JSON="${FECO_ROOT}/data/tags.json"
ORG="${FECO_GITHUB_ORG:-VitaSound}"
GIT_SCHEME="${FECO_GIT_SCHEME:-ssh}"

# CLI tools with bin/<name> launchers (order matters for bashrc output).
FECO_CLI_TOOLS=(fmix flint fcov fmcp fhdlgen)

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: missing tool '$1'. Install with: $2" >&2
    exit 1
  }
}

feco_workspace() {
  if [ -n "${FECO_WORKSPACE:-}" ]; then
    echo "$FECO_WORKSPACE"
    return
  fi
  dirname "$FECO_ROOT"
}

feco_mode() {
  case "${FECO_MODE:-user}" in
    user|dev) echo "${FECO_MODE:-user}" ;;
    *) echo "ERROR: FECO_MODE must be 'user' or 'dev' (got: ${FECO_MODE})" >&2; exit 1 ;;
  esac
}

repo_url() {
  local repo=$1
  case "$GIT_SCHEME" in
    ssh)   echo "git@github.com:${ORG}/${repo}.git" ;;
    https) echo "https://github.com/${ORG}/${repo}.git" ;;
    *) echo "ERROR: FECO_GIT_SCHEME must be 'ssh' or 'https'" >&2; exit 1 ;;
  esac
}

read_repos() {
  grep -v '^[[:space:]]*#' "$CATALOG" | grep -v '^[[:space:]]*$'
}

repo_tags() {
  local repo=$1
  git ls-remote --tags "$(repo_url "$repo")" 2>/dev/null \
    | grep -v '\^{}$' \
    | awk -F/ '{print $NF}' \
    | sed 's/^v//' \
    | grep -E '^[0-9]' \
    | sort -V
}

repo_latest_tag() {
  repo_tags "$1" | tail -1
}

repo_latest_tag_from_json() {
  local repo=$1
  jq -r --arg r "$repo" '.repos[$r].latest // empty' "$TAGS_JSON" 2>/dev/null
}

# Default branch: from local clone, or ls-remote before clone.
repo_default_branch() {
  local repo=$1
  local dir="${2:-$(feco_workspace)/$repo}"
  local branch=""

  if [ -d "$dir/.git" ]; then
    branch="$(git -C "$dir" remote show origin 2>/dev/null \
      | awk '/HEAD branch/ {print $NF; exit}')"
  fi

  if [ -z "$branch" ]; then
    branch="$(git ls-remote --symref "$(repo_url "$repo")" HEAD 2>/dev/null \
      | awk '/^ref: refs\/heads\// {sub(/.*heads\//,""); sub(/\t.*/,""); print; exit}')"
  fi

  if [ -z "$branch" ]; then
    echo "main"
  else
    echo "$branch"
  fi
}

tool_home_var() {
  local tool=$1
  echo "${tool^^}_HOME"
}

tool_home_path() {
  local tool=$1
  local ws
  ws="$(feco_workspace)"
  echo "${ws%/}/$tool"
}

is_cli_tool() {
  local repo=$1
  local ws dir
  ws="$(feco_workspace)"
  dir="${ws%/}/$repo"
  [ -x "$dir/bin/$repo" ]
}

detect_cli_tools() {
  local ws tool
  ws="$(feco_workspace)"
  for tool in "${FECO_CLI_TOOLS[@]}"; do
    if [ -x "${ws%/}/$tool/bin/$tool" ]; then
      echo "$tool"
    fi
  done
}

bashrc_configured() {
  local tool=$1
  local home_var path profile="${HOME}/.bashrc"
  home_var="$(tool_home_var "$tool")"
  path="$(tool_home_path "$tool")"

  [ -f "$profile" ] || return 1
  grep -qF "${home_var}=" "$profile" 2>/dev/null \
    || grep -qF "/$tool/bin" "$profile" 2>/dev/null \
    || grep -qF "$path" "$profile" 2>/dev/null
}

semver_ge() {
  # True if $1 >= $2 (sort -V).
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | tail -1)" = "$1" ]
}

gforth_version() {
  gforth --version 2>&1 | head -1 | awk '{print $2}' | sed 's/_.*//' | tr -d '\r\n' || true
}

check_system_deps() {
  local ver gforth_path

  need git "sudo apt install git"
  need jq  "sudo apt install jq"

  if ! command -v gforth >/dev/null 2>&1; then
    echo "ERROR: gforth not found. Install: sudo apt install gforth (>= 0.7.9)" >&2
    echo "       or build under ~/opt/gforth-0.7.9 and add to PATH." >&2
    exit 1
  fi

  gforth_path="$(command -v gforth)"
  case "$gforth_path" in
    /snap/bin/gforth)
      echo "[!] WARNING: gforth from snap breaks fmix (cwd/path). Prefer apt or ~/opt/gforth-0.7.9." >&2
      ;;
  esac

  ver="$(gforth_version)"
  if [ -z "$ver" ] || ! semver_ge "$ver" "0.7.9"; then
    echo "ERROR: gforth >= 0.7.9 required (found: ${ver:-unknown})" >&2
    exit 1
  fi
  echo "[ok] gforth $ver ($gforth_path)" >&2

  for cmd in sed cp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "[!] WARNING: '$cmd' not found — needed by fmix." >&2
    fi
  done
}

check_pending_patches() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "[i] OS patch check skipped (apt not available)." >&2
    return 0
  fi

  local count
  count="$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)"
  # First line is header "Listing..."
  if [ "${count:-0}" -gt 1 ]; then
    count=$((count - 1))
    echo "[!] $count OS package update(s) available. Recommended:" >&2
    echo "    sudo apt update && sudo apt upgrade" >&2
  else
    echo "[ok] No pending apt upgrades (or cache stale — run: sudo apt update)." >&2
  fi
}

print_bashrc_snippet() {
  local ws tool home_var path missing=() configured=()
  ws="$(feco_workspace)"

  echo ""
  echo "=== Shell setup (~/.bashrc) ==="
  echo "Canonical rules: $FECO_ROOT/docs/shell-setup.md"
  echo "Workspace: $ws"
  echo ""

  while IFS= read -r tool; do
    [ -n "$tool" ] || continue
    if bashrc_configured "$tool"; then
      configured+=("$tool")
    else
      missing+=("$tool")
    fi
  done < <(detect_cli_tools)

  if [ "${#configured[@]}" -gt 0 ]; then
    echo "Already in ~/.bashrc:"
    for tool in "${configured[@]}"; do
      echo "  ✓ $tool"
    done
    echo ""
  fi

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "All detected CLI tools appear configured in ~/.bashrc."
    echo ""
    return 0
  fi

  echo "Add to ~/.bashrc (or ~/.zshrc) — two lines per tool, do not merge PATH:"
  echo ""
  echo "# VitaSound Forth tooling (from feco clone-ecosystem.sh)"
  for tool in "${missing[@]}"; do
    home_var="$(tool_home_var "$tool")"
    path="$(tool_home_path "$tool")"
    echo "export ${home_var}=\"${path}\""
    echo "export PATH=\"\$${home_var}/bin:\$PATH\""
    echo ""
  done
  echo "# Then: source ~/.bashrc"
  echo ""
  echo "Do NOT use: alias fmix='gforth \"\$FMIX_HOME/fmix.4th\" -e'"
  echo ""
}

sync_repo_ref() {
  local repo=$1
  local mode=$2
  local dir ref branch latest

  dir="$(feco_workspace)/$repo"
  [ -d "$dir/.git" ] || return 0

  GIT_TERMINAL_PROMPT=0 git -C "$dir" fetch origin --tags --force >&2

  if [ "$mode" = dev ]; then
    branch="$(repo_default_branch "$repo" "$dir")"
    GIT_TERMINAL_PROMPT=0 git -C "$dir" checkout "$branch" >&2
    GIT_TERMINAL_PROMPT=0 git -C "$dir" pull --ff-only origin "$branch" >&2
    ref="$(git -C "$dir" rev-parse --short HEAD)"
    echo "$repo @ $branch ($ref) mode=dev" >&2
    return 0
  fi

  latest="$(repo_latest_tag_from_json "$repo")"
  if [ -z "$latest" ]; then
    latest="$(repo_latest_tag "$repo")"
  fi

  if [ -z "$latest" ]; then
    branch="$(repo_default_branch "$repo" "$dir")"
    echo "[!] $repo: no semver tags — staying on branch $branch" >&2
    GIT_TERMINAL_PROMPT=0 git -C "$dir" checkout "$branch" >&2
    ref="$(git -C "$dir" rev-parse --short HEAD)"
    echo "$repo @ $branch ($ref) mode=user (no tags)" >&2
    return 0
  fi

  GIT_TERMINAL_PROMPT=0 git -C "$dir" \
    -c advice.detachedHead=false checkout --force "$latest" >&2
  echo "$repo @ $latest mode=user" >&2
}

clone_repo() {
  local repo=$1
  local mode=$2
  local ws dir url

  ws="$(feco_workspace)"
  dir="${ws%/}/$repo"
  url="$(repo_url "$repo")"

  if [ -d "$dir/.git" ]; then
    echo "[skip] $repo — already cloned at $dir" >&2
    sync_repo_ref "$repo" "$mode"
    return 0
  fi

  if [ -e "$dir" ]; then
    echo "ERROR: $dir exists but is not a git repo" >&2
    exit 1
  fi

  echo "[clone] $repo → $dir" >&2
  GIT_TERMINAL_PROMPT=0 git -c advice.detachedHead=false clone "$url" "$dir" >&2
  sync_repo_ref "$repo" "$mode"
}

repo_last_updated_date() {
  local repo=$1
  local dir tag date
  dir="$(feco_workspace)/$repo"
  [ -d "$dir/.git" ] || return 0
  tag="$(git -C "$dir" describe --tags --abbrev=0 2>/dev/null || true)"
  [ -n "$tag" ] || return 0
  git -C "$dir" log -1 --format=%cs "$tag" 2>/dev/null || true
}
