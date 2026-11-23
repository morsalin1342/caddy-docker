#!/bin/bash
# Compare each version pinned in the Dockerfile with the latest upstream release,
# and exit non-zero, listing what is behind, if any pin is older.
#
# Checked: Caddy (the version in the FROM lines, against the latest GitHub
# release of caddyserver/caddy), each xcaddy --with plugin and the --replace of
# golang.org/x/net (against the latest version the Go module proxy reports).
#
# Needs bash, curl and jq. GITHUB_TOKEN, when set, is sent to the GitHub API to
# avoid its rate limit for anonymous requests.
#
# Usage: scripts/check-upstream.sh [path/to/Dockerfile]
set -euo pipefail

DOCKERFILE=${1:-Dockerfile}
GOPROXY_URL=${GOPROXY_URL:-https://proxy.golang.org}

behind=()
failed=()

fetch() {
    curl -fsSL --retry 3 --max-time 30 "$@"
}

github_latest() {
    local auth=()
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    fetch "${auth[@]}" -H 'Accept: application/vnd.github+json' \
        "https://api.github.com/repos/$1/releases/latest" | jq -er '.tag_name'
}

# The Go module proxy escapes upper-case letters in module paths as !lower.
goproxy_latest() {
    local escaped
    escaped=$(printf '%s' "$1" | sed -E 's/([A-Z])/!\L\1/g')
    fetch "${GOPROXY_URL}/${escaped}/@latest" | jq -er '.Version'
}

# compare NAME PINNED LATEST: record NAME as behind when LATEST sorts after PINNED.
compare() {
    local name=$1 pinned=$2 latest=$3
    if [ -z "$latest" ]; then
        failed+=("$name")
        printf '%-50s %-40s %s\n' "$name" "$pinned" "(could not read the latest version)"
    elif [ "${pinned#v}" = "${latest#v}" ]; then
        printf '%-50s %-40s %s\n' "$name" "$pinned" "up to date"
    elif [ "$(printf '%s\n%s\n' "${pinned#v}" "${latest#v}" | sort -V | tail -n 1)" = "${latest#v}" ]; then
        behind+=("$name $pinned -> $latest")
        printf '%-50s %-40s %s\n' "$name" "$pinned" "BEHIND: $latest"
    else
        printf '%-50s %-40s %s\n' "$name" "$pinned" "newer than the latest release ($latest)"
    fi
}

[ -f "$DOCKERFILE" ] || { echo "No $DOCKERFILE here." >&2; exit 2; }

# Caddy, from the FROM lines (caddy:<version>-builder and caddy:<version>).
mapfile -t caddy_pins < <(grep -oP '^FROM caddy:\K[0-9]+\.[0-9]+\.[0-9]+' "$DOCKERFILE" | sort -u)
if [ "${#caddy_pins[@]}" -ne 1 ]; then
    echo "The FROM lines name ${#caddy_pins[@]} different Caddy versions: ${caddy_pins[*]:-none}" >&2
    exit 2
fi
compare "caddy (FROM lines)" "${caddy_pins[0]}" "$(github_latest caddyserver/caddy || true)"

# Plugins: --with <module>@<version>.
while read -r module version; do
    compare "$module" "$version" "$(goproxy_latest "$module" || true)"
done < <(grep -oP -- '--with \K[^@[:space:]]+@[^[:space:]\\]+' "$DOCKERFILE" | tr '@' ' ')

# Replacements: --replace <module>=<module>@<version>.
while read -r module version; do
    compare "$module (replace)" "$version" "$(goproxy_latest "$module" || true)"
done < <(grep -oP -- '--replace [^=]+=\K[^@[:space:]]+@[^[:space:]\\]+' "$DOCKERFILE" | tr '@' ' ')

echo
if [ "${#failed[@]}" -gt 0 ]; then
    echo "Could not check: ${failed[*]}"
fi
if [ "${#behind[@]}" -gt 0 ]; then
    echo "Behind upstream:"
    printf '  %s\n' "${behind[@]}"
    exit 1
fi
if [ "${#failed[@]}" -gt 0 ]; then
    exit 2
fi
echo "Every pin is at the latest upstream release."
