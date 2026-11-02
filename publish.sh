#!/usr/bin/env bash
# Reproducible publish for talos-hq/demo3: fetch -> secret scan -> link report -> stage.
# Usage: ./publish.sh            (fetch + scan + write index.html/source/)
#        ./publish.sh --verify   (check live Pages URL: HTTP 200 + title in body)
set -euo pipefail
SRC_URL="https://gist.githubusercontent.com/Alana11nextus/8aa64596e531c729aa09c722fa3911f1/raw/zachvorhies-home-DEPLOY-index.html"
PAGES_URL="https://talos-hq.github.io/demo3/"
TITLE="Zach Vorhies — Google Whistleblower | Google Leaks"
cd "$(dirname "$0")"

if [[ "${1:-}" == "--verify" ]]; then
  for i in $(seq 1 20); do   # bounded: 20 x 15s = 5 min max
    code=$(curl -sSL -o /tmp/demo3-live.html -w '%{http_code}' "$PAGES_URL" || true)
    if [[ "$code" == 200 ]] && grep -qF "<title>$TITLE</title>" /tmp/demo3-live.html; then
      curl -sS -o /dev/null -w 'no-follow: %{http_code} -> %{redirect_url}\n' "$PAGES_URL"; echo "HTTP $code (after redirects); title found: $TITLE"; exit 0; fi
    echo "attempt $i: HTTP $code"; sleep 15
  done
  echo "verify FAILED"; exit 1
fi

tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
curl -sSfL -o "$tmp" "$SRC_URL"

# Secret scan: tokens, keys, private emails, internal hostnames. Any hit aborts.
# The only email allowed is the public contact address printed on the page itself.
hits=$(grep -nEo 'gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[abpr]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY|(api[_-]?key|secret[_-]?key|access[_-]?token|password)["'"'"' ]*[:=]|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|localhost|127\.0\.0\.1|192\.168\.[0-9.]+|10\.[0-9]+\.[0-9]+\.[0-9]+|[a-z0-9.-]+\.(internal|local|corp|lan)\b' "$tmp" \
  | grep -v ':zach@zachvorhies\.com$' || true)
if [[ -n "$hits" ]]; then echo "SECRET SCAN FAILED:"; echo "$hits"; exit 1; fi
echo "secret scan: clean"

grep -q "<title>$TITLE</title>" "$tmp" || { echo "title changed upstream; update TITLE"; exit 1; }
echo "root-relative links (break under /demo3/):"
grep -oE '(src|href)="/[^"]*"' "$tmp" | sort -u

cp "$tmp" source/zachvorhies-home-DEPLOY-index.html
cp "$tmp" index.html
touch .nojekyll
echo "staged index.html (sha256 $(sha256sum index.html | cut -c1-16))"
