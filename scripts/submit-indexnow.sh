#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Key filename = key contents (IndexNow convention)
KEY_FILE="$(ls "$ROOT"/docs/*.txt 2>/dev/null | while read -r f; do
  base=$(basename "$f" .txt)
  if [[ "$base" =~ ^[a-f0-9]{32}$ ]] && [[ $(cat "$f") == "$base" ]]; then echo "$f"; break; fi
done)"
if [[ -z "${KEY_FILE:-}" ]]; then
  echo "No IndexNow key file in docs/" >&2
  exit 1
fi
KEY="$(basename "$KEY_FILE" .txt)"
HOST="kramlipi.github.io"
URLS_JSON=$(curl -fsS "https://${HOST}/sitemap.xml" | grep -oP '(?<=<loc>)[^<]+' | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')
BODY=$(python3 -c "import json; print(json.dumps({'host':'$HOST','key':'$KEY','keyLocation':'https://$HOST/$KEY.txt','urlList':json.loads('''$URLS_JSON''')}))")
echo "Submitting to IndexNow (Bing & partners)..."
CODE=$(curl -sS -o /tmp/indexnow-out.txt -w "%{http_code}" -X POST "https://api.indexnow.org/indexnow" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$BODY")
echo "HTTP $CODE"
cat /tmp/indexnow-out.txt; echo
[[ "$CODE" == "200" || "$CODE" == "202" ]] || exit 1
